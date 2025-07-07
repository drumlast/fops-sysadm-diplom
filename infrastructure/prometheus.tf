resource "yandex_compute_instance" "prometheus" {
  name = "prometheus"
  platform_id = "standard-v3"

  resources { cores = 2, memory = 4 }

  boot_disk {
    initialize_params { image_id = var.image_id }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
    nat       = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key)}"
  }
}