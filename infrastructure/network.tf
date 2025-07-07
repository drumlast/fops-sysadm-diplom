resource "yandex_vpc_network" "main_net" {
  name = "main-net"
}

resource "yandex_vpc_subnet" "private" {
  name           = "private-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.main_net.id
  v4_cidr_blocks = ["10.10.1.0/24"]
}

resource "yandex_vpc_subnet" "public" {
  name           = "public-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.main_net.id
  v4_cidr_blocks = ["10.10.2.0/24"]
}