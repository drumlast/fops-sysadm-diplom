# VPC
resource "yandex_vpc_network" "main" {
  name = "main-network"
}

# Публичная подсеть (для ALB, Grafana, Kibana, bastion)
resource "yandex_vpc_subnet" "public" {
  name           = "public-subnet"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.10.0.0/24"]
}

# Приватная подсеть (для web, prometheus, elasticsearch)
resource "yandex_vpc_subnet" "private" {
  name           = "private-subnet"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.20.0.0/24"]
  route_table_id = yandex_vpc_route_table.nat.id
}

# Таблица маршрутов для NAT
resource "yandex_vpc_route_table" "nat" {
  name       = "nat-route-table"
  network_id = yandex_vpc_network.main.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat.network_interface.0.ip_address
  }
}

# Security Group для bastion
resource "yandex_vpc_security_group" "bastion" {
  name       = "bastion-sg"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# NAT-инстанс (bastion)
resource "yandex_compute_instance" "nat" {
  name        = "nat-instance"
  platform_id = "standard-v3"
  zone        = var.yc_zone

  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.bastion.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.public_ssh_key}"
  }
}

# Настройка NAT-функций на instance
resource "null_resource" "nat_setup" {
  depends_on = [yandex_compute_instance.nat]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = yandex_compute_instance.nat.network_interface.0.nat_ip_address
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
    }

    inline = [
      "sudo sysctl -w net.ipv4.ip_forward=1",
      "sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf",
      "echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections",
      "echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections",
      "sudo DEBIAN_FRONTEND=noninteractive apt update",
      "sudo DEBIAN_FRONTEND=noninteractive apt install -y iptables-persistent",
      "sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE",
      "sudo netfilter-persistent save"
    ]
  }
}