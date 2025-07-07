resource "yandex_compute_instance" "elasticsearch" {
  name = "elasticsearch"
  platform_id = "standard-v3"

  resources { cores = 4, memory = 8 }

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