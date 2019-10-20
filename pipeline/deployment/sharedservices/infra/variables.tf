# #####################################
# FILENAME: variables.tf
# USAGE:
#   Defines the terraform variable definitions for main.tf template
# #####################################

# =====================================
# SECTION: azurerm variables
# DEFINES:
#   1. azurerm_environment
#   2. azurerm_subscription_id
#   3. azurerm_tenant_id
# =====================================

variable "azurerm_environment" {
  type = "string"
}

variable "azurerm_subscription_id" {
  type = "string"
}

variable "azurerm_tenant_id" {
  type = "string"
}

# =====================================
# SECTION: shared service variables
# DEFINES:
#   1. shared_service_rg 
#   2. shared_service_vnet
#   3. shared_service_subnet
# =====================================

variable "shared_service_rg" {
  type = "string"
}

variable "shared_service_vnet" {
  type = "string"
}

variable "shared_service_subnet" {
  type = "string"
}

# =====================================
# SECTION: gsbproxy variables
# DEFINES:
#   01. gsbproxy_rg 
#   02. gsbproxy_location
#   03. gsbproxy_vmss_name
#   04. gsbproxy_vmss_username
#   05. gsbproxy_vmss_ssh_pub_key
#   06. gsbproxy_vmss_tag_environment
#   07. gsbproxy_vmss_lb_name 
#   08. gsbproxy_vmss_nsg_name
#   09. gsbproxy_vmss_lb_ip
#   10. gsbproxy_vmss_dnsserver_ip
#   11. gsbproxy_vmss_autoscale_name
#   12. gsbproxy_vmss_autoscale_location
# =====================================

variable "gsbproxy_rg" {
  type = "string"
}

variable "gsbproxy_location" {
  type = "string"
}

variable "gsbproxy_vmss_name" {
  type = "string"
}

variable "gsbproxy_vmss_username" {
  type = "string"
}

variable "gsbproxy_vmss_ssh_pub_key" {
  type = "string"
}

variable "gsbproxy_vmss_tag_environment" {
  type = "string"
}

variable "gsbproxy_vmss_lb_name" {
  type = "string"
}

variable "gsbproxy_vmss_nsg_name" {
  type = "string"
}

variable "gsbproxy_vmss_lb_ip" {
  type = "string"
}

variable "gsbproxy_vmss_dnsserver_ip" {
  type = "string"
}

variable "gsbproxy_vmss_autoscale_name" {
  type = "string"
}

variable "gsbproxy_vmss_autoscale_location" {
  type = "string"
}
# =====================================
# SECTION: vault variables
# DEFINES:
#   1. vault_address
#   2. vault_path
#   3. vault_role
# =====================================

variable "vault_address" {
  type = "string"
}

variable "vault_path" {
  type = "string"
}

variable "vault_role" {
  type = "string"
}

variable "custom_image_resource_group_name" {
  type = "string"
}

variable "custom_image_name" {
  type = "string"
}

