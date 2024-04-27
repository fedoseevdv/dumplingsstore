module "yandex_cloud_network" {
    nw_vpc_subnets_list_names = var.nw_vpc_subnets_list_names

    source = "./modules/tf-yc-network"
}

module "yandex_storage_bucket" {
    bucket_network_zone = "${var.network_region}"
    bucket_private_storage_max_size = var.bucket_private_storage_max_size
    bucket_public_storage_max_size = var.bucket_public_storage_max_size
    bucket_public_storage_name = var.bucket_public_storage_name
    bucket_private_storage_name = var.bucket_private_storage_name
    bucket_folder_id = "${var.folder_id}"

    source = "./modules/tf-yc-bucket"
}

module "yandex_kubernetes_cluster" {
    k8s_network_subnet_id = module.yandex_cloud_network.yandex_vpc_subnets_map["${var.current_network_zone}"].id
    k8s_network_id = module.yandex_cloud_network.yandex_vpc_network_map.id
    k8s_network_zone = "${var.current_network_zone}"
    k8s_enable_public_ip = true
    k8s_folder_id = "${var.folder_id}"
    k8s_service_account_name = "${var.yc_service_account}"
    k8s_node_memory = var.node_memory
    k8s_node_cpu = var.node_cpu
    k8s_node_min_nodes_count = var.node_min_nodes_count
    k8s_node_max_nodes_count = var.node_max_nodes_count
    k8s_node_initial_nodes_count = var.node_initial_nodes_count

    source = "./modules/tf-yc-k8s-zone"
}

