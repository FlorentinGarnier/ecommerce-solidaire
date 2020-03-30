FROM php:7.2-cli

MAINTAINER Florentin Garnier <florentin@digital404.fr>

RUN apt-get update && apt-get install -y \
    libicu-dev \
    libzip-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    cron \
    wkhtmltopdf \
    && apt-get clean

RUN docker-php-ext-install -j$(nproc) pdo_mysql opcache pcntl intl zip exif\
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

COPY cronjob /etc/cron.d/001-cronjob

RUN chmod 0644 /etc/cron.d/001-cronjob

RUN crontab /etc/cron.d/001-cronjob

RUN touch /var/log/cron.log

WORKDIR /srv

CMD ["cron", "-f"]
