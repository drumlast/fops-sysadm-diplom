resource "yandex_vpc_security_group" "web" {
  name       = "web-sg"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"] # трафик от ALB или проверки
  }

  ingress {
    protocol            = "TCP"
    port                = 22
    security_group_id   = yandex_vpc_security_group.bastion.id
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_compute_instance" "web" {
  count       = 2
  name        = "web-${count.index + 1}"
  platform_id = "standard-v3"
  zone        = element(["ru-central1-a", "ru-central1-b"], count.index)

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
    subnet_id          = yandex_vpc_subnet.private.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.web.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.public_ssh_key}"
  }

  labels = {
    role = "web"
  }
}