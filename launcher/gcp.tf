provider "google" {
  project     = "${var.var_project}"
  credentials = "${file("trl-trial-101-a36657d98b71.json")}"
  region      = "${var.region}"
}

locals {
  default_zone = "asia-southeast1-a"
}

resource "google_compute_instance" "admin_instance" {

  name         = "trilia-launcher"
  machine_type = "f1-micro"
  zone         = "${local.default_zone}"

  tags = ["instance-name", "trilia-launcher"]

  boot_disk {
    initialize_params {
      image = "trl-ubuntu-bionic-image"
    }
  }

  // Local SSD disk
  //scratch_disk {
  //  interface = "SCSI"
  //}

  network_interface {
  
    //network = "${google_compute_network.admin_vpc.self_link}"
	subnetwork = "${google_compute_subnetwork.admin_subnet[0].self_link}"

    access_config {
       //Ephemeral IP
	  
    }
  }

  metadata = {
    ssh-keys = "${var.gce_ssh_user}:${file(var.public_key_file)}"
  }

  #metadata_startup_script = "echo hi > /test.txt"

  #service_account {
  #  scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  #}
  
    provisioner "file" {
		source = "trl-trial-1.ppk"
		destination = "/tmp/trl-trial-1.ppk"

		connection {
		  type        = "ssh"
		  user        = "ghosh_rajesh_gmail_com"
		  private_key = "${file(var.ssh_key_private)}"
		  host 		  = "${self.network_interface.0.access_config.0.nat_ip}"
		}
	}
	
	provisioner "file" {
		source = "trl-trial-1.pem"
		destination = "/tmp/trl-trial-1.pem"

		connection {
		  type        = "ssh"
		  user        = "ghosh_rajesh_gmail_com"
		  private_key = "${file(var.ssh_key_private)}"
		  host 		  = "${self.network_interface.0.access_config.0.nat_ip}"
		}
	}
	
	provisioner "file" {
		source = "trl-trial-1.pub"
		destination = "/tmp/trl-trial-1.pub"

		connection {
		  type        = "ssh"
		  user        = "ghosh_rajesh_gmail_com"
		  private_key = "${file(var.ssh_key_private)}"
		  host 		  = "${self.network_interface.0.access_config.0.nat_ip}"
		}
	}
	
	provisioner "remote-exec" {
		inline = [
			
			"dos2unix /tmp/trl-trial-1.ppk; dos2unix /tmp/trl-trial-1.pem; dos2unix /tmp/trl-trial-1.pub;"
		]
		
		connection {
			type        = "ssh"
			user        = "ghosh_rajesh_gmail_com"
			private_key = "${file(var.ssh_key_private)}"
			host 		  = "${self.network_interface.0.access_config.0.nat_ip}"
		}
	}
  
}

resource "google_compute_disk" "launcher-disk" {

  name  = "trl-launcher-disk"
  type  = "pd-standard"
  zone  = "${local.default_zone}"
  size  = "10"
  labels = {
    environment = "dev"
  }
  physical_block_size_bytes = 4096
}


resource "google_compute_attached_disk" "launcher-disk-attach" {

  depends_on = [google_compute_disk.launcher-disk , google_compute_instance.admin_instance]

  disk     = google_compute_disk.launcher-disk.self_link
  instance = google_compute_instance.admin_instance.self_link
}

resource "null_resource" "mount_ebs_volume" {
	
	depends_on = [google_compute_attached_disk.launcher-disk-attach]
	
	provisioner "remote-exec" {
		
		inline = [
		    "sudo mkdir /trilia_ci",
			"sudo chmod 755 /trilia_ci",
			"sudo mkfs -t ext4 /dev/sdb",
			"sudo mount /dev/sdb /trilia_ci",
			"sudo chown -R ubuntu:ubuntu /trilia_ci",
			"sudo mv /tmp/trl-trial-1.ppk /trilia_ci",
			"sudo chown ubuntu:ubuntu /trilia_ci/trl-trial-1.ppk",
			"sudo chmod 600 /trilia_ci/trl-trial-1.ppk",
			"sudo mv /tmp/trl-trial-1.pem /trilia_ci",
			"sudo chown ubuntu:ubuntu /trilia_ci/trl-trial-1.pem",
			"sudo chmod 600 /trilia_ci/trl-trial-1.pem",
			"sudo mv /tmp/trl-trial-1.pub /trilia_ci",
			"sudo chown ubuntu:ubuntu /trilia_ci/trl-trial-1.pub",
			"sudo chmod 600 /trilia_ci/trl-trial-1.pub",
		]

		connection {
		  type        = "ssh"
		  user        = "ghosh_rajesh_gmail_com"
		  private_key = "${file(var.ssh_key_private)}"
		  host 		  = "${google_compute_instance.admin_instance.network_interface.0.access_config.0.nat_ip}"
		}
	
	}

}

//resource "null_resource" "unmount_ebs_volume" {
//	
//	depends_on = [google_compute_instance.admin_instance]
//	
//	provisioner "remote-exec" {
//		
//		when = "destroy"
//		
//		inline = [
//			"sudo umount -f /dev/sdb"
//		]
//
//		connection {
//		  type        = "ssh"
//		  user        = "ghosh_rajesh_gmail_com"
//		  private_key = "${file(var.ssh_key_private)}"
//		  host 		  = "${google_compute_instance.admin_instance.network_interface.0.access_config.0.nat_ip}"
//		}
//	
//	}
//
//}

resource "null_resource" "checkout_tf" {

	depends_on = [null_resource.mount_ebs_volume]
	
	provisioner "remote-exec" {
		
		inline = [
		    "cd /trilia_ci",
			"sudo -u ubuntu git clone https://github.com/trilia/gcp-db-stack.git",
			"cd gcp-db-stack/test/compact/kubeprep",
			"sudo -u ubuntu terraform init -input=false",
		]

		connection {
		  type        = "ssh"
		  user        = "ghosh_rajesh_gmail_com"
		  private_key = "${file(var.ssh_key_private)}"
		  host 		  = "${google_compute_instance.admin_instance.network_interface.0.access_config.0.nat_ip}"
		}
	
	}
	
}

output "public_ip" {
	value = "${google_compute_instance.admin_instance.network_interface.0.access_config.0.nat_ip}"
}