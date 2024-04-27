variable "token" {
  description = "Yandex Cloud Token"
  type        = string
  nullable    = false
  sensitive   = true
}

variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
  nullable    = false
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
  nullable    = false
}

variable "current_network_zone" {
  description = "Yandex.Cloud selected network zone"
  type        = string
  default     = "ru-central1-a"
  nullable    = false
}

variable "nw_vpc_subnets_list_names" {
  description = "Yandex.Cloud network availability zones list (set)"
  type        = set(string)
  default     = ["ru-central1-a"]
  nullable    = false
}

variable "bucket_private_storage_max_size" {
  description = "Private storage max size in bytes"
  type        = number
  default     = 536870912
  nullable    = false
}

variable "bucket_public_storage_max_size" {
  description = "Public storage max size in bytes"
  type        = number
  default     = 2147483648
  nullable    = false
}

variable "bucket_private_storage_name" {
  description = "Private storage bucket name"
  type        = string
  default     = "dumplings-store-tf-state-object-storage"
  nullable    = false
}

variable "bucket_public_storage_name" {
  description = "Public storage bucket name"
  type        = string
  default     = "dumplings-store-public-object-storage"
  nullable    = false
}

variable "network_region" {
  description = "Kubernetes network region"
  type        = string
  default     = "ru-central1"
  nullable    = false
}

variable "yc_service_account" {
  description = "Kubernetes service acount name"
  type        = string
  default     = "devops-editor"
  nullable    = false
}

variable "node_cpu" {
  description = "Kubernetes nodes CPU count"
  type        = number
  default     = 2
  nullable    = true
}

variable "node_memory" {
  description = "Kubernetes nodes memory size"
  type        = number
  default     = 2
  nullable    = true
}

variable "node_initial_nodes_count" {
  description = "Kubernetes nodes initial count"
  type        = number
  default     = 1
  nullable    = true
}

variable "node_max_nodes_count" {
  description = "Kubernetes nodes maximum count"
  type        = number
  default     = 2
  nullable    = true
}

variable "node_min_nodes_count" {
  description = "Kubernetes nodes minimal count"
  type        = number
  default     = 1
  nullable    = true
}
