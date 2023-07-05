variable "auth_url"	{}
variable "project_domain_name" {}
variable "user_domain_name"	{}
variable "region"	{}
variable "user_name"	{}
variable "password"	{}
variable "ssh_key_public" {}
variable "ssh_key_private" {}
variable "floating_ip_pool" {}
variable "unique_network_name"	{}
variable "server_name" {}

provider "openstack" {
  auth_url            = "${var.auth_url}"
  project_domain_name = "${var.project_domain_name}"
  user_domain_name    = "${var.user_domain_name}"
  region              = "${var.region}"
  user_name           = "${var.user_name}"
  password            = "${var.password}"
}

output "terraform-provider" {
    value = "Connected with OpenStack at ${var.auth_url}"
}
