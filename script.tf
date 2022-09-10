terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = "YOUR_TOKEN"
  cloud_id  = "YOUR_CLOUD"
  folder_id = "YOUR_FOLDER"
  zone      = "ru-central1-a"
}



resource "yandex_vpc_network" "net1" {
  name = "net1"
  labels = {
    "cmlinstance" = "1"
  }
}

resource "yandex_vpc_subnet" "subnet1" {
    zone       = "ru-central1-a"
    network_id = "${yandex_vpc_network.net1.id}"
    v4_cidr_blocks = ["10.1.0.0/24"]
      labels = {
    "cmlinstance" = "1"
  }
}

resource "yandex_compute_instance" "cml" {
  name = "cml"
  platform_id = "standard-v3"
  boot_disk {
      initialize_params {
        image_id = "fd8dgd53le1aj6gul69o"
        size = 32
      }
    }

    labels = {
    "cmlinstance" = "1"
  }
  network_interface {
      subnet_id = "${yandex_vpc_subnet.subnet1.id}"
      nat = true
    }
    metadata = {
    user-data = "${file("meta.txt")}"
}
  resources {
      cores = 2
      memory = 2
      core_fraction = 100
      
    }

}


output "connect_ip" {
  value = "https://${yandex_compute_instance.cml.network_interface[0].nat_ip_address}"
}


output "cml_username" {
  value =  "admin"
  
}

output "cml_password" {
  value = "P@ssw0rd"
  
}
