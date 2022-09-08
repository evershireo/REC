terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = "YOUR TOKEN"
  cloud_id  = "YOUR CLOUD"
  folder_id = "YOUR FOLDER"
  zone      = "ru-central1-a"
}



resource "yandex_vpc_network" "net1" {
  name = "net1"
  labels = {
    "to" = "cml"
  }
}

resource "yandex_vpc_subnet" "subnet1" {
    zone       = "ru-central1-a"
    network_id = "${yandex_vpc_network.net1.id}"
    v4_cidr_blocks = ["10.1.0.0/24"]
      labels = {
    "to" = "cml"
  }
}

resource "yandex_compute_instance" "cml" {
  name = "cml"
  hostname = "cml"
  platform_id = "standard-v3"
  boot_disk {
      initialize_params {
        image_id = "fd81e1d53tn2c6gnsqtt"
        size = 32
      }
    }

    labels = {
    "to" = "cml"
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


output "connect_ip" {
  value = "${yandex_compute_instance.cml.network_interface[0].nat_ip_address}"
}

