
locals {
  admin_subnet1_cidr 	= "${var.admin_vpc_subnet_prefix}.0.0/${var.admin_subnet_netid_bits}"
  admin_subnet2_cidr    = "${var.admin_vpc_subnet_prefix}.80.0/${var.admin_subnet_netid_bits}"
  admin_subnet3_cidr 	= "${var.admin_vpc_subnet_prefix}.160.0/${var.admin_subnet_netid_bits}"
}


resource "google_compute_network" "admin_vpc" {

  name 						= "${var.admin_vpc_name}"
  auto_create_subnetworks 	= "false"
  routing_mode            	= "GLOBAL"

}


resource "google_compute_firewall" "admin_fw" {

  name    = "trl-admin-fw"
  network = "${google_compute_network.admin_vpc.self_link}"
  
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  source_ranges = [
    "0.0.0.0/0"
  ]
  
}

resource "google_compute_subnetwork" "admin_subnet" {

  count = 3

  name          = "trl-admin-subnet-${count.index}"
  ip_cidr_range = "${var.admin_vpc_subnet_prefix}.${format(count.index * 80)}.0/${var.admin_subnet_netid_bits}"
  network       = "${google_compute_network.admin_vpc.self_link}"
  region        = "${var.region}"
  
}


