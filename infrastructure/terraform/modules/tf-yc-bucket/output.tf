output "public_storage" {
  value = yandex_storage_bucket.public_storage
}

output "private_storage" {
  value = yandex_storage_bucket.private_storage
}

output "storage_access_key" {
  value = "${yandex_iam_service_account_static_access_key.sa-static-key.secret_key}"

  sensitive = true
}

output "storage_access_key_id" {
  value = "${yandex_iam_service_account_static_access_key.sa-static-key.access_key}"
}