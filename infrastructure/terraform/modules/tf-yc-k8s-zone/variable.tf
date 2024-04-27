variable "k8s_service_account_name" {
  description = "Kubernetes service account name"
  type        = string
  default     = "devops-editor"
  nullable    = false
}

variable "k8s_cluster_name" {
  description = "Kubernetes cluster name"
  type        = string
  default     = ""
  nullable    = true
}

variable "k8s_cluster_version" {
  description = "Kubernetes cluster version"
  type        = string
  default     = "1.26"
  nullable    = false
}

variable "k8s_enable_public_ip" {
  description = "Kubernetes enable/disable external ip access"
  type        = bool
  nullable    = false
}

variable "k8s_network_subnet_id" {
  description = "Kubernetes network subnet id"
  type        = string
  nullable    = false
}

variable "k8s_network_zone" {
  description = "Kubernetes network zone"
  type        = string
  nullable    = false
}

variable "k8s_network_id" {
  description = "Kubernetes network id"
  type        = string
  nullable    = false
}

variable "k8s_folder_id" {
  description = "Kubernetes yandex cloud folder id"
  type        = string
  nullable    = false
}

variable "k8s_master_logging_enabled" {
  description = "Kubernetes logging enable/disable"
  type        = bool
  default     = true
  nullable    = true
}

variable "k8s_master_logging_log_group_id" {
  description = "Kubernetes logging group id"
  type        = string
  default     = ""
  nullable    = true
}

variable "k8s_master_logging_kube_apiserver_enabled" {
  description = "Kubernetes logging api server enable/disable"
  type        = bool
  default     = true
  nullable    = true
}

variable "k8s_master_logging_cluster_autoscaler_enabled" {
  description = "Kubernetes logging autoscaler enable/disable"
  type        = bool
  default     = true
  nullable    = true
}

variable "k8s_master_logging_events_enabled" {
  description = "Kubernetes logging events enable/disable"
  type        = bool
  default     = true
  nullable    = true
}

variable "k8s_master_logging_audit_enabled" {
  description = "Kubernetes logging audit enable/disable"
  type        = bool
  default     = true
  nullable    = true
}

variable "k8s_kms_key_rotation_period" {
  description = "Kubernetes kms key rotation period"
  type        = string
  default     = "8760h"
  nullable    = true
}

variable "k8s_node_initial_nodes_count" {
  description = "Kubernetes nodes initial count"
  type        = number
  default     = 1
  nullable    = true
}

variable "k8s_node_max_nodes_count" {
  description = "Kubernetes nodes maximum count"
  type        = number
  default     = 2
  nullable    = true
}

variable "k8s_node_min_nodes_count" {
  description = "Kubernetes nodes minimal count"
  type        = number
  default     = 1
  nullable    = true
}

variable "k8s_node_container_runtime" {
  description = "Kubernetes nodes container runtime type"
  type        = string
  default     = "containerd"
  nullable    = false
}

variable "k8s_node_hdd_type" {
  description = "Kubernetes nodes HDD type"
  type        = string
  default     = "network-hdd"
  nullable    = true
}

variable "k8s_node_hdd_size" {
  description = "Kubernetes nodes HDD size"
  type        = number
  default     = 30
  nullable    = false

  validation {
    condition     = var.k8s_node_hdd_size >= 30
    error_message = "Size of data disk must be greater than 30 Gb."
  }
}

variable "k8s_node_nat" {
  description = "Kubernetes nodes nat enable/disable"
  type        = bool
  default     = true
  nullable    = false
}

variable "k8s_node_cpu" {
  description = "Kubernetes nodes CPU count"
  type        = number
  default     = 2
  nullable    = true
}

variable "k8s_node_memory" {
  description = "Kubernetes nodes memory size"
  type        = number
  default     = 2
  nullable    = true
}

variable "k8s_node_platform_id" {
  description = "Kubernetes nodes platform ID"
  type        = string
  default     = "standard-v2"
  nullable    = true
}
