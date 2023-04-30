# Required providers
terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.48.0"
    }
  }
}

# Openstack Keystone endpoint
variable "os_api_url" {
}

# Openstack project
variable "os_project" {
}

# Openstack user
variable "os_user" {
}

# Openstack password
variable "os_password" {
}

# OpenStack Provider configuration
provider "openstack" {
  user_name   = var.os_user
  tenant_name = var.os_project
  password    = var.os_password
  auth_url    = var.os_api_url
  region      = "RegionOne"
}
