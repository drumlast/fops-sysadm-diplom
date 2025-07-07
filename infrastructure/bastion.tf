resource "yandex_compute_instance" "bastion" {
  name        = "bastion"
  platform_id = "standard-v3"

  resources { cores = 2, memory = 2 }

  boot_disk {
    initialize_params { image_id = var.image_id }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key)}"
  }
}