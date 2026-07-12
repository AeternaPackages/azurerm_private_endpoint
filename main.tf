locals {
  private_endpoints = { for k1, v1 in var.private_endpoints : k1 => { custom_network_interface_name = v1.custom_network_interface_name, ip_configuration = v1.ip_configuration, location = v1.location, name = v1.name, private_dns_zone_group = v1.private_dns_zone_group, private_service_connection = v1.private_service_connection, resource_group_name = v1.resource_group_name, subnet_id = v1.subnet_id, tags = v1.tags } }

  private_endpoint_application_security_group_associations = merge([
    for k1, v1 in var.private_endpoints : {
      for k2, v2 in coalesce(v1.private_endpoint_application_security_group_associations, {}) :
      "${k1}/${k2}" => merge(v2, {
        private_endpoint_id = module.private_endpoints.private_endpoints_id["${k1}"]
      })
    }
  ]...)
}

module "private_endpoints" {
  source            = "git::https://github.com/AeternaModules/azurerm_private_endpoint.git?ref=v4.80.0"
  private_endpoints = local.private_endpoints
}

module "private_endpoint_application_security_group_associations" {
  source                                                   = "git::https://github.com/AeternaModules/azurerm_private_endpoint_application_security_group_association.git?ref=v4.80.0"
  private_endpoint_application_security_group_associations = local.private_endpoint_application_security_group_associations
  depends_on                                               = [module.private_endpoints]
}

