variable "private_endpoints" {
  description = <<EOT
Map of private_endpoints, attributes below
Required:
    - location
    - name
    - resource_group_name
    - subnet_id
    - private_service_connection (block)
Optional:
    - custom_network_interface_name
    - tags
    - ip_configuration (block)
    - private_dns_zone_group (block)
Nested private_endpoint_application_security_group_associations (azurerm_private_endpoint_application_security_group_association):
    Required:
        - application_security_group_id
EOT

  type = map(object({
    location                      = string
    name                          = string
    resource_group_name           = string
    subnet_id                     = string
    custom_network_interface_name = optional(string)
    tags                          = optional(map(string))
    private_service_connection = object({
      is_manual_connection              = bool
      name                              = string
      private_connection_resource_alias = optional(string)
      private_connection_resource_id    = optional(string)
      request_message                   = optional(string)
      subresource_names                 = optional(list(string))
    })
    ip_configuration = optional(list(object({
      member_name        = optional(string)
      name               = string
      private_ip_address = string
      subresource_name   = optional(string)
    })))
    private_dns_zone_group = optional(object({
      name                 = string
      private_dns_zone_ids = list(string)
    }))
    private_endpoint_application_security_group_associations = optional(map(object({
      application_security_group_id = string
    })))
  }))

  validation {
    condition = alltrue(concat(
      [for kk in keys(var.private_endpoints) : !strcontains(kk, "/")],
      flatten([for k0, v0 in var.private_endpoints : [for kk in keys(coalesce(v0.private_endpoint_application_security_group_associations, {})) : !strcontains(kk, "/")]])
    ))
    error_message = "Map keys in this package must not contain '/': it is used internally as a nesting-key separator, so a key containing it can silently collide two different nested entries into one. Rename the offending key(s)."
  }
}
