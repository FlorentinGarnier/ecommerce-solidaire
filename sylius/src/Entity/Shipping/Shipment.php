<?php

declare(strict_types=1);

namespace App\Entity\Shipping;

use CoopTilleuls\SyliusClickNCollectPlugin\Entity\ClickNCollectShipment;
use CoopTilleuls\SyliusClickNCollectPlugin\Entity\ClickNCollectShipmentInterface;
use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\Core\Model\Shipment as BaseShipment;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_shipment")
 */
class Shipment extends BaseShipment implements ClickNCollectShipmentInterface
{
    use ClickNCollectShipment;
}
