
provider "google" {
  project     = "${var.var_project}"
  credentials = "${file(var.gcp_cred_file)}"
  region      = "${var.region}"
}

data "google_compute_network" "db_network" {
  name = "${var.db_vpc_name}"
}

data "google_compute_subnetwork" "subnet_0" {
  name = "${var.db_subnet_0}"
}

resource "google_container_cluster" "primary" {

  name     = "trl-gke-cluster"
  location = "${var.gke_master_loc}"
  node_locations = "${var.gke_cluster_zones}"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  
  remove_default_node_pool = true
  initial_node_count       = 1

  network = "${data.google_compute_network.db_network.self_link}"
  subnetwork = "${data.google_compute_subnetwork.subnet_0.self_link}"

  master_auth {
    username = "admin"
    password = "Welcome!23456789"

    client_certificate_config {
      issue_client_certificate = false
    }
  }
  
  //node_config {
  //	disk_size_gb = "10"
  //	disk_type = "pd-standard"
  //}
  
  node_config {
  
    preemptible  = false
    machine_type = "g1-small"
	disk_size_gb = 10
	image_type = "ubuntu"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
  
}

resource "google_container_node_pool" "primary_nodes" {

  name       = "trl-gke-node-pool"
  location   = "${var.gke_master_loc}"
  cluster    = "${google_container_cluster.primary.name}"
  node_count = 1

  node_config {
  
    preemptible  = false
    machine_type = "g1-small"
	disk_size_gb = 10
	
  }
  
}
