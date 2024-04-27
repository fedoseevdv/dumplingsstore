variable "bucket_sa" {
  description = "Bucket administrator account name"
  type        = string
  default     = "bucket-sa"
  nullable    = false
}

variable "bucket_folder_id" {
  description = "Bucket Folder ID"
  type        = string
  nullable    = false
}

variable "bucket_network_zone" {
  description = "Network Zone"
  type        = string
  nullable    = false
}

variable "bucket_private_storage_max_size" {
  description = "Private bucket storage max size in bytes"
  type        = number
  default     = 536870912
  nullable    = false
}

variable "bucket_public_storage_max_size" {
  description = "Public bucket storage max size in bytes"
  type        = number
  default     = 2147483648
  nullable    = false
}

variable "bucket_private_storage_name" {
  description = "Private bucket storage name"
  type        = string
  default     = "dumplings-store-tf-state-object-storage"
  nullable    = false
}

variable "bucket_public_storage_name" {
  description = "Public bucket storage name"
  type        = string
  default     = "dumplings-store-public-object-storage"
  nullable    = false
}
