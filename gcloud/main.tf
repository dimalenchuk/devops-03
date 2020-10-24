provider "google" {
  credentials = file("focal-freedom-292312-ce620a51c481.json")
  project = "focal-freedom-292312"
  region  = "us-east1"
  zone    = "us-east1-b"
  user_project_override = true
}

resource "google_compute_instance" "vm_instance" {
  name = "${var.name}-${count.index+1}"
  machine_type = "f1-micro"
  count = 2
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  tags = ["${google_compute_firewall.default.name}"]

  network_interface {
    network = google_compute_network.vpc_network.self_link
    access_config {
    }
  }
  metadata = {
    ssh-keys = "dimalenchuk:${file("C:/Users/dimal/.ssh/id_rsa.pub")}"
  }
  provisioner "local-exec" {
      command = "echo ${self.network_interface[var.nwindex+1].access_config[var.nwindex+1].nat_ip} >> ips.txt"
  }
  provisioner "remote-exec" {
      inline = [
          "echo ${self.network_interface[var.nwindex+1].access_config[var.nwindex+1].nat_ip} >> ~/IP-address.txt"
      ]
    
      connection {
          type = "ssh"
          user = "dimalenchuk"
          private_key = file("~/.ssh/id_rsa")
          host = self.network_interface[var.nwindex+1].access_config[var.nwindex+1].nat_ip
      }
  }
}

output "ip_addr" {
  value = "${google_compute_instance.vm_instance.*.network_interface.0.access_config.0.nat_ip}"
}

resource "google_compute_firewall" "default" {
  name    = "devops-03"
  network = google_compute_network.vpc_network.name
  allow {
      protocol = "tcp"
      ports = ["22"]
  }
  allow {
    protocol = "tcp"
    ports    = ["80-9090"]
  }
}


resource "google_compute_network" "vpc_network" {
  name                    = "my-network-38"
  auto_create_subnetworks = "true"
}
