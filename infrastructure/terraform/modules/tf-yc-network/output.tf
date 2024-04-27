output "yandex_vpc_subnets_map" {
  description = "Yandex.Cloud Subnets map"
  value       = data.yandex_vpc_subnet.subnets_list
}

output "yandex_vpc_network_map" {
  description = "Yandex.Cloud Network map"
  value       = data.yandex_vpc_network.this
}

