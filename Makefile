DOCKER_COMPOSE?=docker-compose
RUN?=docker run --rm
EXEC?=$(DOCKER_COMPOSE) exec
DATABASE?=db
DATETIME?=$(shell date +"%Y%m%d")
BASEDIR?=$$PWD
CURRENT_DIR?=$(shell basename $(BASEDIR) | tr '[:upper:]' '[:lower:]')
NETWORK?=$(CURRENT_DIR)_default


.DEFAULT_GOAL: help

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: pma
pma: ## Lauch PhpMyAdmin
	$(RUN) --network $(NETWORK) -p 8081:80 --link db:db --name pma phpmyadmin/phpmyadmin

.PHONY: database-dump
database-dump: ## Dump database
	$(EXEC) $(DATABASE) bash -c 'mysqldump -u "$$MYSQL_USER" -p"$$MYSQL_PASSWORD" "$$MYSQL_DATABASE"' | gzip > database/dump-$(DATETIME).sql.gz


##Application Management

.PHONY: install-prod
install-prod:
	$(DOCKER_COMPOSE) exec php composer install --no-dev --optimize-autoloader
	$(DOCKER_COMPOSE) run encore yarn
	$(DOCKER_COMPOSE) run encore yarn encore production

	chmod -R 777 var/*

.PHONY: compile-asset-prod
compile-asset-prod: sylius/node_modules ## Compile Assets
	$(DOCKER_COMPOSE) run encore yarn encore production

.PHONY: compile-asset-dev
compile-asset-dev: sylius/node_modules ## Compile Assets
	$(DOCKER_COMPOSE) run encore yarn encore dev

.PHONY: install
install: sylius/node_modules
	$(DOCKER_COMPOSE) exec php composer install
	$(DOCKER_COMPOSE) run encore yarn build
	chmod -R 777 var/*


.PHONY: build
build: docker-compose.override.yml ## Build de l'application
	$(DOCKER_COMPOSE) pull
	$(DOCKER_COMPOSE) build

.PHONY: start
start: ## Lance l'application
	$(DOCKER_COMPOSE) up -d


.PHONY: update
update: ## Mise à jour de l'application
	$(DOCKER_COMPOSE) exec php composer update
	chmod -r 777 var/*

.PHONY: update-prod
update-prod: ## Mise à jour de l'application
	$(DOCKER_COMPOSE) exec php composer update --no-dev --optimize-autoloader
	chmod -r 777 var/*

.PHONY: logs
logs: ## Affiche les logs
	$(DOCKER_COMPOSE) logs -f

.PHONY: stop
stop: ## Arrête l'application
	$(DOCKER_COMPOSE) stop

.PHONY: clean
clean: ## Efface l'application
	$(DOCKER_COMPOSE) down -v

##Symfony
.PHONY: cc
cc: ## Clear Cache
	$(DOCKER_COMPOSE) exec php php bin/console c:c

##Sylius

.PHONY: sylius-install
sylius-install: ## Installe Sylius
	$(DOCKER_COMPOSE) exec php php bin/console sylius:install

sylius/node_modules: sylius/package.json
	$(DOCKER_COMPOSE) run encore yarn install
	touch sylius/node_modules
