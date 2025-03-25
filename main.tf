terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = ">=0.129.0"
    }
  }
  required_version = ">= 1.8.4"
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
}

data "yandex_vpc_network" "network" {					# Если сеть уже создана
  name  = "region-b"
}

# Создание публичной подсети (subnet A)
resource "yandex_vpc_subnet" "public_subnet_a" {
  name           = "public-subnet-a"
  zone           = "ru-central1-a"
  network_id     = data.yandex_vpc_network.network.id	# Если создаем новую сеть data необходимо убрать
  v4_cidr_blocks = ["192.168.10.0/24"]
}

# Web Servers
resource "yandex_compute_instance" "vm1" {
  name = "web-server-1"
  zone = "ru-central1-a"

  resources {
    memory = 2
    cores  = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd83s8u085j3mq231ago"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public_subnet_a.id
    nat = true
  }

  metadata = {
    user-data = "${file("~/homework/15.6/shvirtd-example-python/meta.txt")}"
  }

#  scheduling_policy { preemptible = true }

}

output "vm1_public_ip" {
  value = yandex_compute_instance.vm1.network_interface.0.nat_ip_address
  description = "Публичный IP адрес VM1"
}
