variable "nw_vpc_subnets_list_names" {
  description = "Yandex.Cloud network availability zones list (set)"
  type        = set(string)
  default     = ["ru-central1-a"]
  nullable    = false
}
