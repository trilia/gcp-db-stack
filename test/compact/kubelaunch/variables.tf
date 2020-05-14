variable "region" {
  default = "asia-southeast1"
}

variable "var_project" {
        default = "trl-trial-101"
}

variable "gke_master_loc" {
  default = "asia-southeast1-a"
}

variable "gke_cluster_zones" {
  type = list(string)
  default = ["asia-southeast1-b"]
}


variable "db_vpc_name" {
        default = "trl-compact-prod-db-cluster-vpc-db"
}

variable "db_subnet_0" {
  default = "trl-db-subnet-0"
}


