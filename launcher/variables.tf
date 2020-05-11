
variable "var_project" {
	default = "trl-trial-101"
}

variable "public_key_file" {
  default = "trl-trial-1.pub"
}

variable "gce_ssh_user" {
  default = "ghosh_rajesh_gmail_com"
}

variable "region" {
  default = "asia-southeast1"
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

variable "admin_subnet_netid_bits" {
	default = "26"
}

variable "ssh_key_private" {
	default = "D:\\Projects\\Terraform\\trilia\\gcp_stack\\launcher\\trl-trial-1.pem"
}

