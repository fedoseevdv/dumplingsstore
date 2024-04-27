output "cluster_id" {
  value = "${module.yandex_kubernetes_cluster.this.id}"
}

output "cluster_name" {
  value = "${module.yandex_kubernetes_cluster.this.name}"
}

output "cluster_cert" {
  value = "${base64encode(module.yandex_kubernetes_cluster.this.master[0].cluster_ca_certificate)}"
}

output "cluster_endpoint" {
  value = "${module.yandex_kubernetes_cluster.this.master[0].external_v4_endpoint}"
}

output "cluster_public_info" {
   value = <<-EOT
Resources successfully created:
---
apiVersion: v1
clusters:
- cluster:
    server: ${module.yandex_kubernetes_cluster.this.master[0].external_v4_endpoint}
    certificate-authority-data: [..]
  name: ${module.yandex_kubernetes_cluster.this.name}
users:
- name: ${module.yandex_kubernetes_cluster.account.name}
  user:
    [..]

#To get the kubectl config, please provide:
yc managed-kubernetes cluster get-credentials --id ${module.yandex_kubernetes_cluster.this.id} --external

EOT
}

output "public_storage_info" {
  value = <<EOT
    endpoint   = storage.yandexcloud.net
    bucket     = ${module.yandex_storage_bucket.public_storage.bucket}
    region     = ${var.network_region}
EOT
}

output "private_state_storage_terraform_full_access_info" {
  value = <<EOT
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "${module.yandex_storage_bucket.private_storage.bucket}"
    region     = "${var.network_region}"
    key        = "terraform/terraform.tfstate"
    access_key = "${module.yandex_storage_bucket.storage_access_key_id}"
    secret_key = "${module.yandex_storage_bucket.storage_access_key}"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
EOT

  sensitive = true
}

output "bucket_access_id" {
  value = "${module.yandex_storage_bucket.storage_access_key_id}"
  
  sensitive = true
}

output "bucket_access_key" {
  value = "${module.yandex_storage_bucket.storage_access_key}"
  
  sensitive = true
}

output "cluster_access_id" {
  value = "${module.yandex_kubernetes_cluster.account}"
  
  sensitive = true
}

output "cluster_access_key" {
  value = "${module.yandex_kubernetes_cluster.key}"
  
  sensitive = true
}