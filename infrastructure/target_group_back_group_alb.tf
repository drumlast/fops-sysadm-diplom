resource "yandex_alb_target_group" "tg_web" {
  name = "tg-web"

  target {
    subnet_id = yandex_vpc_subnet.private.id
    address   = yandex_compute_instance.nginx1.network_interface[0].ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.private.id
    address   = yandex_compute_instance.nginx2.network_interface[0].ip_address
  }
}

resource "yandex_alb_backend_group" "bg_web" {
  name = "bg-web"

  http_backend {
    name             = "backend-nginx"
    target_group_ids = [yandex_alb_target_group.tg_web.id]
    port             = 80

    healthcheck {
      http_healthcheck { path = "/" }
    }
  }
}

resource "yandex_alb_http_router" "router_web" {
  name = "router-web"
}

resource "yandex_alb_virtual_host" "vh_web" {
  name           = "vh-web"
  http_router_id = yandex_alb_http_router.router_web.id

  route {
    name = "route-main"
    http_route {
      http_match { path = { prefix = "/" } }
      backend_group_id = yandex_alb_backend_group.bg_web.id
    }
  }
}

resource "yandex_alb_load_balancer" "alb_web" {
  name = "alb-web"

  network_id = yandex_vpc_network.main_net.id

  allocation_policy { location { zone_id = "ru-central1-a" } }

  listener {
    name = "listener-web"
    endpoint { address_type = "external" ports = ["80"] }
    http { router_id = yandex_alb_http_router.router_web.id }
  }
}