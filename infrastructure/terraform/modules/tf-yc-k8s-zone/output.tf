output "this" {
    value = yandex_kubernetes_cluster.k8sc
}

output "key" {
    value = yandex_iam_service_account_key.sa-auth-key
}

output "account" {
    value = yandex_iam_service_account.k8smanager

}
