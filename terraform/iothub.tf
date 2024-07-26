resource "azurerm_iothub" "iothub" {
  name                = "iothub-cedihegi-${var.environment_short}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  // The number of device-to-cloud partitions used by backing event hubs. 2-128
  event_hub_partition_count = 4
  // Specifies how long this IoT hub will maintain device-to-cloud events, between 1 and 7 days.
  event_hub_retention_in_days = 7
  // Returns: Requested IoT Hub features '\"MinimumTlsVersion1_2\"' not available in 'switzerlandnorth' region.
  // min_tls_version = "1.2"
  // For the first Delyoment, the public Network has to be true, after first deplyomend set it to false! The resolve and attachement of te PE does not work
  public_network_access_enabled = true

  sku {
    name     = "S1"
    capacity = 1
  }

  network_rule_set {
    apply_to_builtin_eventhub_endpoint = false
    default_action                     = "Deny"
    ip_rule {
      name = "allow-noser"
      ip_mask = "212.103.80.53/24"
    }
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_private_endpoint" "pe-iothub" {
  name                = "pe-iothub"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.subnet.id

  private_service_connection {
    name                           = "iot-hub-connection"
    private_connection_resource_id = azurerm_iothub.iothub.id
    subresource_names              = ["iotHub"]
    is_manual_connection           = false
  }
}
