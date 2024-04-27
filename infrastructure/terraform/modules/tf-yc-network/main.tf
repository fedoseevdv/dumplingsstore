data "yandex_vpc_network" "this" {
  name        = "default"
}

data "yandex_vpc_subnet" "subnets_list" {
  for_each    = var.nw_vpc_subnets_list_names

  name        = "${data.yandex_vpc_network.this.name}-${each.key}"
}
