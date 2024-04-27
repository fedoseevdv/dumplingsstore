Модуль "yandex_kubernetes_cluster" (tf-yc-k8s-zone) является частью дипломной работы.
-------------------------------------------------------------------------------------

Модуль является вспомогательным, основным предназначением которого, является создание зонального kubernets cluster (источник https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster);

Модуль создает последовательно создает:
- объект лог-группа (yandex_logging_group, источник https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/logging_group)
- ресурс yandex_iam_service_account (учетную запись) для управления кластером, источник https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/iam_service_account), также к учетной записи добавляются необходимые роли:
  -- container-registry.images.puller
  -- editor
  -- k8s.clusters.agent
  -- vpc.publicAdmin
  -- kms.keys.encrypterDecrypter
- создается ключ шифрования KMS key (yandex_kms_symmetric_key, источник https://yandex.cloud/ru/docs/kms/tutorials/terraform-key)
- создается объект кластера yandex_kubernetes_cluster (https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster)

Модуль возвращает объекты this, являющийся ссылкой на созданный кластер, а также key и account, указывающие на учетную запись yandex_iam_service_account, которая имеет право на управление объектом кластера. 

Требования: установленная версия провайдера yandex-cloud 0.102.x (поддерживаются любые патчи минорной версии), а также terraform включительно до версии 1.5.x (поддерживаются любые патчи минорной версии).

Важно!
------
Для доступа к провайдеру необходимо наличие ключа (токена) в переменной TF_VAR_token