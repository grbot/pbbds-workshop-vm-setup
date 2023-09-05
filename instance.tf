terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
      version = "~> 1.35.0"
    }
  }
}

resource "openstack_compute_keypair_v2" "terraform-key" {
  name   = "${var.server_name}-key"
  public_key = "${file(var.ssh_key_public)}"
}

resource "openstack_networking_floatingip_v2" "base" {
  pool = "${var.floating_ip_pool}"
  count = 2
}

resource "openstack_compute_floatingip_associate_v2" "base" {
  count = 2
  floating_ip = openstack_networking_floatingip_v2.base[count.index].address
  instance_id = openstack_compute_instance_v2.base[count.index].id
}

resource "openstack_compute_instance_v2" "base" {
    count = 2
    name            = "${var.server_name}-${count.index + 26}"
    image_name      = "20230405-jammy"
    flavor_name     = "ilifu-A"
    image_id        = "e4dda219-c90f-4c8b-8c02-beff460b0be0"
    key_pair        = "${openstack_compute_keypair_v2.terraform-key.name}"
    security_groups = ["default"]

    network {
      name = "${var.unique_network_name}"
    }
}







