
variable "var_project" {
        default = "trl-trial-101"
}

variable "region" {
  default = "asia-southeast1"
}

variable "public_key_file" {
  default = "/trilia_ci/trl-trial-1.pub"
}

variable "gcp_cred_file" {
  default = "/trilia_ci/trl-trial-101-a36657d98b71.json"
}

variable "ssh_key_private" {
        default = "/trilia_ci/trl-trial-1.pem"
}

variable "gce_ssh_user" {
  default = "ghosh_rajesh_gmail_com"
}

variable "admin_vpc_name" {
        default = "trl-admin-vpc"
}

variable "admin_vpc_subnet_prefix" {
        default = "10.28"
}

variable "admin_vpc_netid_bits" {
        default = "16"
}

// Service sub-net related :

variable "svc_cluster_name" {
        default = "trl-compact-prod-service-cluster"
}

variable "svc_vpc_subnet_prefix" {
        default = "10.29"
}

variable "svc_vpc_netid_bits" {
        default = "16"
}

variable "svc_subnet_netid_bits" {
        default = "26"
}

// Service sub-net related :

variable "db_cluster_name" {
        default = "trl-compact-prod-db-cluster"
}

variable "db_vpc_subnet_prefix" {
        default = "10.30"
}

variable "db_vpc_netid_bits" {
        default = "16"
}

variable "db_subnet_netid_bits" {
        default = "26"
}
