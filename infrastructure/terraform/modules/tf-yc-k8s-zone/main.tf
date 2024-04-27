resource "yandex_logging_group" "lg" {
  name        = "logging-group"

  folder_id   = "${var.k8s_folder_id}"
}

resource "yandex_iam_service_account" "k8smanager" {
  name        = "${var.k8s_service_account_name}"
}

resource "yandex_iam_service_account_key" "sa-auth-key" {
  service_account_id = "${yandex_iam_service_account.k8smanager.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "editor" {
  role      = "editor"

  folder_id = "${var.k8s_folder_id}"

  member    = "serviceAccount:${yandex_iam_service_account.k8smanager.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "puller" {
  role        = "container-registry.images.puller"

  folder_id   = "${var.k8s_folder_id}"

  member      = "serviceAccount:${yandex_iam_service_account.k8smanager.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s-clusters-agent" {
  role        = "k8s.clusters.agent"

  folder_id   = "${var.k8s_folder_id}"

  member      = "serviceAccount:${yandex_iam_service_account.k8smanager.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "vpc-public-admin" {
  role        = "vpc.publicAdmin"

  folder_id   = "${var.k8s_folder_id}"

  member      = "serviceAccount:${yandex_iam_service_account.k8smanager.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "encrypterDecrypter" {
  role        = "kms.keys.encrypterDecrypter"

  folder_id   = "${var.k8s_folder_id}"

  member      = "serviceAccount:${yandex_iam_service_account.k8smanager.id}"
}

resource "yandex_kms_symmetric_key" "kms-key" {
  name              = "kms-key"

  default_algorithm = "AES_128"

  rotation_period   = "${var.k8s_kms_key_rotation_period}"
}

resource "yandex_kubernetes_cluster" "k8sc" {
  network_id = "${var.k8s_network_id}"

  name = "${var.k8s_cluster_name}"

  master {
     zonal {
       zone      = "${var.k8s_network_zone}"
       subnet_id = "${var.k8s_network_subnet_id}"
    }

    master_logging {
      enabled                    =  var.k8s_master_logging_enabled
      log_group_id               = "${yandex_logging_group.lg.id}"
      kube_apiserver_enabled     =  var.k8s_master_logging_kube_apiserver_enabled
      cluster_autoscaler_enabled =  var.k8s_master_logging_cluster_autoscaler_enabled
      events_enabled             =  var.k8s_master_logging_events_enabled
      audit_enabled              =  var.k8s_master_logging_audit_enabled
   }

    public_ip = var.k8s_enable_public_ip
  }

  service_account_id      = yandex_iam_service_account.k8smanager.id
  node_service_account_id = yandex_iam_service_account.k8smanager.id

  depends_on = [
    yandex_resourcemanager_folder_iam_member.k8s-clusters-agent,
    yandex_resourcemanager_folder_iam_member.vpc-public-admin,
    yandex_resourcemanager_folder_iam_member.editor,
    yandex_resourcemanager_folder_iam_member.puller
  ]

  kms_provider {
    key_id = yandex_kms_symmetric_key.kms-key.id
  }
}

resource "yandex_kubernetes_node_group" "node_group" {
  cluster_id  = yandex_kubernetes_cluster.k8sc.id

  instance_template {
    platform_id = "${var.k8s_node_platform_id}"

    network_interface {
      nat                = var.k8s_node_nat
      subnet_ids         = ["${var.k8s_network_subnet_id}"]
    }

    resources {
      memory = var.k8s_node_memory
      cores  = var.k8s_node_cpu
    }

    boot_disk {
      type = "${var.k8s_node_hdd_type}"
      size = var.k8s_node_hdd_size
    }

    container_runtime {
      type = "${var.k8s_node_container_runtime}"
    }
  }

  scale_policy {
    auto_scale {
      initial = var.k8s_node_initial_nodes_count
      min = var.k8s_node_min_nodes_count
      max = var.k8s_node_max_nodes_count
    }
    
  }

  allocation_policy {
    location {
      zone = "${var.k8s_network_zone}"
    }
  }
}