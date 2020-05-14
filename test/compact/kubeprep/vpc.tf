
locals {
  default_zone = "asia-southeast1-a"
}

data "google_compute_network" "admin-network" {
  name = "${var.admin_vpc_name}"
}


// ---- Create the service VPC
resource "google_compute_network" "service_vpc" {

  name                                          = "${var.svc_cluster_name}-vpc-service"
  auto_create_subnetworks       = "false"
  routing_mode                  = "GLOBAL"

}

resource "google_compute_subnetwork" "svc_subnet" {

  count = 3

  name          = "trl-svc-subnet-${count.index}"
  ip_cidr_range = "${var.svc_vpc_subnet_prefix}.${format(count.index * 80)}.0/${var.svc_subnet_netid_bits}"
  network       = "${google_compute_network.service_vpc.self_link}"
  region        = "${var.region}"

}

resource "google_compute_firewall" "service_fw_1" {

  // allow access from admin vpc

  name    = "trl-service-fw-int"
  network = "${google_compute_network.service_vpc.self_link}"

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
    "${var.admin_vpc_subnet_prefix}.0.0/${var.admin_vpc_netid_bits}"  // later fine tune admin netid bits for only the one to do service network admin
  ]

}

resource "google_compute_firewall" "service_fw_2" {

  name    = "trl-service-fw-ext"
  network = "${google_compute_network.service_vpc.self_link}"

  //deny {
  //  protocol = "icmp"
  //}

  allow {
    protocol = "tcp"
    ports    = ["7000-9000"]
  }

  //deny {
  //  protocol = "udp"
  //  ports    = ["0-65535"]
  //}

  source_ranges = [
    "0.0.0.0/0"
  ]

}

// ---- Create the db VPC
resource "google_compute_network" "db_vpc" {

  name                                          = "${var.db_cluster_name}-vpc-db"
  auto_create_subnetworks       = "false"
  routing_mode                  = "GLOBAL"

}

resource "google_compute_subnetwork" "db_subnet" {

  count = 3

  name          = "trl-db-subnet-${count.index}"
  ip_cidr_range = "${var.db_vpc_subnet_prefix}.${format(count.index * 80)}.0/${var.db_subnet_netid_bits}"
  network       = "${google_compute_network.db_vpc.self_link}"
  region        = "${var.region}"

}

resource "google_compute_firewall" "db_fw_1" {

  // allow access from admin vpc

  name    = "trl-db-fw-int"
  network = "${google_compute_network.db_vpc.self_link}"

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
    "${var.admin_vpc_subnet_prefix}.0.0/${var.admin_vpc_netid_bits}"  // later fine tune admin netid bits for only the one to do service network admin
  ]

}

resource "google_compute_firewall" "db_fw_2" {

  // allow access from service vpc

  name    = "trl-db-fw-svc"
  network = "${google_compute_network.db_vpc.self_link}"

  //allow {
  //  protocol = "icmp"
  //}

  allow {
    protocol = "tcp"
    ports    = ["27000-28000"]          // allow only mongo ports
  }

  //allow {
  //  protocol = "udp"
  //  ports    = ["0-65535"]
  //}

  source_ranges = [
    "${var.svc_vpc_subnet_prefix}.0.0/${var.svc_vpc_netid_bits}"  // later fine tune admin netid bits for only the one to do service network admin
  ]

}

//resource "google_compute_firewall" "db_fw_3" {

  //name    = "trl-db-fw-ext"
  //network = "${google_compute_network.db_vpc.self_link}"

  //deny {
  //  protocol = "icmp"
  //}

  //allow {
  //  protocol = "tcp"
  //  ports    = ["7000-9000"]
  //}

  //deny {
  //  protocol = "udp"
  //  ports    = ["0-65535"]
  //}

  //source_ranges = [
  //  "0.0.0.0/0"
  //]

//}


// VPC Peering :

//resource "google_compute_network_peering" "admin_2_svc" {
//  name         = "trl-admin-2-svc"
//  network      = "${data.google_compute_network.admin-network.self_link}"
//  peer_network = "${google_compute_network.service_vpc.self_link}"
//}

resource "google_compute_network_peering" "admin_2_db" {
  name         = "trl-admin-2-db"
  network      = "${data.google_compute_network.admin-network.self_link}"
  peer_network = "${google_compute_network.db_vpc.self_link}"
}

resource "google_compute_network_peering" "db_2_admin" {
  name         = "trl-db-2-admin"
  network      = "${google_compute_network.db_vpc.self_link}"
  peer_network = "${data.google_compute_network.admin-network.self_link}"
}

resource "google_compute_network_peering" "svc_2_db" {
  name         = "trl-svc-2-db"
  network      = "${google_compute_network.service_vpc.self_link}"
  peer_network = "${google_compute_network.db_vpc.self_link}"
}

resource "google_compute_network_peering" "db_2_svc" {
  name         = "trl-db-2-svc"
  network      = "${google_compute_network.db_vpc.self_link}"
  peer_network = "${google_compute_network.service_vpc.self_link}"
}
                                            