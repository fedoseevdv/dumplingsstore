Основной terraform-модуль дипломного проекта.
Создание необходимой инфраструктуры для приложения.
---------------------------------------------------

Модуль требует наличия вспомогательных (дочерних) модулей:
- yandex_cloud_network (работа с сетью, сетевые настройки)
- yandex_storage_bucket (объектное хранилище)
- yandex_kubernetes_cluster (kubernetes-кластер)

Модуль использует функцию сохранения бэкнд состояния в S3 Yandex.cloud.
Источник https://cloud.yandex.ru/docs/storage/operations/objects/upload
Однако, в конфигурации не присутстуют учетные данные и параметры сохранения. Вместо это присутствует тег-заглушка #s3_private_block_configuration, которая будет заменена deploy-скриптом на фактические учетные данные уже после создания нужных объектов.

Предназначен для создания и управления виртуальной инфраструктурой с указанными (заданными) параметрами в облаке yandex-cloud для работы приложения Dumplings Store (aka Momo).

Для управления созданием инфраструктуры необходимы следующие обязательные параметры:
- token - токен доступа для yandex-cloud. Может быть получен `yc iam create-token`. 
- cloud_id - идентификатор Cloud. Может быть получен через https://console.cloud.yandex.ru/folders
- folder_id - идентификатор папки, в которой необходимо расположить инфраструктуру.
- current_network_zone - текущая сетевая зона для k8s кластера. Объект из модуля yandex_cloud_network
- nw_vpc_subnets_list_names - сетевой регион из Yandex cloud. Объект из модуля yandex_cloud_network
- bucket_private_storage_max_size - Размер в байтах создаваемого частного объектного хранилища. Объект из модуля yandex_storage_bucket
- bucket_public_storage_max_size - Размер в байтах создаваемого публичного объектного хранилища. Объект из модуля yandex_storage_bucket
- bucket_private_storage_name - Наименование создаваемого частного объектного хранилища. Объект из модуля yandex_storage_bucket
- bucket_public_storage_name - Наименование создаваемого публичного объектного хранилища. Объект из модуля yandex_storage_bucket
- network_region - сетевой регион из Yandex cloud. Объект из модуля yandex_cloud_network
- yc_service_account - сервисный аккаунт (наименование) для управления кластером k8s 

Кроме того, присутствует возможность задать необязательные параметры:
- node_cpu: число CPU на создаваемой kubernetes node
- node_memory: объем оперативной памяти для создаваемой kubernetes node
- node_initial_nodes_count: число создавемых объектов kubernetes node (на момент создания) 
- node_max_nodes_count: число создавемых объектов kubernetes node (максимум) 
- node_min_nodes_count: число создавемых объектов kubernetes node (минимум) 

Модуль, после успешного создания кластера kubernetes возвращает:
- cluster_id: идентификатор kubernetes кластера
- cluster_name: имя созданного kubernetes кластера
- cluster_cert: сертификат созданного kubernetes кластера
- cluster_endpoint: endpoint созданного kubernetes кластера (точка доступа, url)
- cluster_public_info: визуальный блок доступа (будущий kubeconfig блок), не содержащий конфеденциальных данных
- public_storage_info: данные по созданному публичному объектному хранилищу
- private_state_storage_terraform_full_access_info: данные по созданному приватному объектному хранилищу для сохранения статуса работы terraform
- bucket_access_id: идентификатор (имя) учетной записи для доступа к объектным хранилищам
- bucket_access_key: токен учетной записи для доступа к объектным хранилищам
- cluster_access_id: идентификатор (имя) учетной записи для доступа к kubernetes-кластеру
- cluster_access_key: токен учетной записи для доступа к kubernetes-кластеру

Требования: установленная версия провайдера yandex-cloud 0.102.x (поддерживаются любые патчи минорной версии), а также terraform включительно до версии 1.5.x (поддерживаются любые патчи минорной версии).

Важно!
------
Для доступа к провайдеру необходимо наличие ключа (токена) в переменной TF_VAR_token
(источник: https://developer.hashicorp.com/terraform/language/settings/backends/s3)