#!/bin/bash
set -u
declare -i REMOVE_APPLICATION=0
declare -i DESTROY_CLUSTER=0
declare -i SKIP_CLONE=0
declare -i NO_INFRASTRUCTURE=0

#Destination path
#Папка назначения, куда будет распакованы скрипты перед созданием кластера
APP_HOME=./

#Application Name
#Имя приложения
APP_NAME="Dumplings Store"

#Caution! Application global URL!
#Важно! По этой ссылке будет доступно приложение из-вне
export FRONTEND_EXTERNAL_FQDN="dumplingsstore.ru"

#Secrets store name for cert-manager
#Наименование secrets store для хранения данных сертификата от cert-manager
export TLS_STORE_SECRET_NAME="dumplings-store-tls-secret"

#Terraform client version
#Версия клиента Terraform
TERRAFORM_VERSION=1.5.7

#Helm client version
#Версия Helm-клиента
HELM_VERSION=3.14.2

#Terraform platofm (based on local pc)
#Архитектура клиентской машины, где будет запускаться этот скрипт
ARCHITECTURE=amd64

#Object storage to create at the cloud
#Public object storage url for public resources
#Данный ресурс будет использоваться для обмена с облачной папкой, где расположены статические изображения, пельменной
PUBLIC_OBJECT_STORAGE_NAME=dumplings-store-public-object-storage
#Private storage
#Хранилище используется для резервирования файла terraform
PRIVATE_TF_STATE_OBJECT_STORAGE_NAME=dumplings-store-tf-state-object-storage

#Repository
#Путь к данному репозиторию
REPOSITORY=https://gitlab.praktikum-services.ru/std-ext-001-027/diploma.git
#Путь к образам репозитория. Используется для получения готовых сборок и применения их в Kubernetes
REPOSITORY_IMAGES_URL=gitlab.praktikum-services.ru:5050/std-ext-001-027/diploma/

#-----------------------Yandex Cloud---------------------------
#yandex_folder
YC_FOLDER_ID=b1gncb1kcc73r5htu4ag
YC_CLOUD_ID=b1gt9ii9bedoqvg3plll

YC_SERVICE_ACCOUNT=devops-editor


#k8s external account full access
#учетная запись в kubernetes в режиме полного доступа
export CLUSTER_ADMIN=cluster-admin

#builded images ids
#Данные идентификаторы образов будут развернуты в кластере
FRONTEND_IMAGE_VERSION=1.0.1188071
BACKEND_IMAGE_VERSION=1.0.1188043

if [[ $EUID -eq 0 ]]; then
   echo "This script cannot be run as super-user!" 
   exit 5
fi

echo "$APP_NAME deployment script."
echo ""

show_help() {
  echo "Usage: $(basename "$0") [options]"
  echo "Options:"
  echo "  -h, --help              Show help (this screen)."

  echo "  -d, --delete            Destroy all (application and k8s cluster)."
  echo "  -r, --remove            Delete the application from cluster."
  echo "  -n, --no_infrastructure Skip terraform cluster creating (use your own)."
  echo "  -s, --skip_clone        Skip repository clone."
  echo ""
  echo "Sample: $(basename "$0") -d"
}

#---
trap "echo 'Wrong options.' && show_help && exit 1" ERR
OPTIONS=$(getopt -o "hrdsn " -l "help,delete,remove,skip_clone,no_infrastructure" -- "$@" 2>/dev/null)

eval set -- "$OPTIONS"

while true; do
  if [[ $# -eq 0 ]]; then
     break
  fi

  case "$1" in
    -d|--delete)
      DESTROY_CLUSTER=1
      shift
    ;;

    -r|--remove)
      REMOVE_APPLICATION=1
      shift
    ;;

    -s|--skip_clone)
      SKIP_CLONE=1
      shift
    ;;

    -n|--no_infrastructure)
      NO_INFRASTRUCTURE=1
      shift
    ;;

    -h|--help)
      show_help
      exit 0
      ;;

    --)
      shift
      break ;;

    *)
      echo "Wrong argument: $1"
      show_help
      exit 0
      ;;
  esac
done

trap - ERR
#---

if [[ $REMOVE_APPLICATION == 1 ]]; then
  "${APP_HOME}dist/helm/helm" delete "dumplings-store" "${APP_HOME}diploma/infrastructure/kubernetes/dumplings-store-chart"

  echo ""
  exit $?
fi

if [[ $REMOVE_APPLICATION == 0 && $DESTROY_CLUSTER == 0 ]]; then
  echo "Preparing..."
  echo "============"

  mkdir -p ./dist
  mkdir -p ./dist/terraform
  mkdir -p ./dist/helm
  mkdir -p ./dist/yandex-cloud
  mkdir -p ./dist/rclone
  mkdir -p ./dist/kubernetes

  if [[ ! $SKIP_CLONE -eq 1 ]]; then
    echo "Getting the application..."
    echo "--------------------------"
    if [[ $? -eq 0 ]]; then
      echo "Please provide your account name below."
    fi
    echo ""
    git clone $REPOSITORY

    if [[ ! $? -eq 0 ]]; then
      echo "Clone repository error."
      echo -e "You aslo can skip this stage with: \n $(basename "$0") --skip_clone"
      echo "Exiting..."
      exit $?
    fi
    else echo "Skiping repository clonning..."
  fi

  if [[ ! $NO_INFRASTRUCTURE -eq 1 ]]; then
    export TF_VAR_bucket_public_storage_name=$PUBLIC_OBJECT_STORAGE_NAME
    export TF_VAR_bucket_private_storage_name=$PRIVATE_TF_STATE_OBJECT_STORAGE_NAME
  
    echo ""
    echo "Getting the Teraform..."
    echo "-----------------------"
    echo "https://hashicorp-releases.yandexcloud.net/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${ARCHITECTURE}.zip"
    wget --no-check-certificate "https://hashicorp-releases.yandexcloud.net/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${ARCHITECTURE}.zip" \
         -O "${APP_HOME}dist/terraform/terraform.zip" && unzip -o "${APP_HOME}dist/terraform/terraform.zip" -d "${APP_HOME}dist/terraform"

    if [ -e ~/.terraformrc ]; then
      echo ""
      echo "The configuration of terraform is exist on the local computer!"

      while true; do
        read -p "Be careful! Can it be replaced? " yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) echo "Aboring..."; exit 5;;
            * ) echo "Please answer yes or no.";;
        esac
      done
    fi

    touch ~/.terraformrc && echo 'provider_installation {
    network_mirror {
    url = "https://terraform-mirror.yandexcloud.net/"
      include = ["registry.terraform.io/*/*"]
    }
    direct {
      exclude = ["registry.terraform.io/*/*"]
    }
    }' > ~/.terraformrc

    echo ""
    echo "Yandex Cloud CLI installation..."
    echo "--------------------------------"
    wget "https://storage.yandexcloud.net/yandexcloud-yc/install.sh" -O "${APP_HOME}dist/yandex-cloud/install.sh" --no-check-certificate && chmod +x "${APP_HOME}dist/yandex-cloud/install.sh" && "${APP_HOME}dist/yandex-cloud/install.sh" -n -i "${APP_HOME}dist/yandex-cloud"
  fi

  echo ""
  echo "Getting the Helm..."
  echo "-------------------"
  HELM_FILE="helm-v${HELM_VERSION}-linux-${ARCHITECTURE}.tar.gz" && curl "https://get.helm.sh/$HELM_FILE" --output "${APP_HOME}dist/helm/$HELM_FILE" && tar -zxvf "${APP_HOME}dist/helm/$HELM_FILE" --directory="${APP_HOME}dist/helm" --strip=1

  echo ""
  echo "Installing RClone..."
  curl https://downloads.rclone.org/rclone-current-linux-${ARCHITECTURE}.zip --output "${APP_HOME}dist/rclone/rclone.zip" && unzip -jo "${APP_HOME}dist/rclone/rclone.zip" -d "${APP_HOME}dist/rclone/"

  echo ""
  echo "Kubectl installation..."
  curl -LO https://dl.k8s.io/release/v1.29.2/bin/linux/amd64/kubectl && mv ./kubectl "${APP_HOME}dist/kubernetes/" && chmod +x "${APP_HOME}dist/kubernetes/kubectl"

  echo ""
  echo "Initialization phase"
  echo "===================="

  echo ""
  echo "Yandex Cloud initialization..."
  echo "------------------------------"
  "${APP_HOME}dist/yandex-cloud/bin/yc" init
fi

if [[ ! $NO_INFRASTRUCTURE -eq 1 ]]; then
  echo ""
  echo "Terraform initialization..."
  echo "---------------------------"

  export TF_VAR_token=$("${APP_HOME}dist/yandex-cloud/bin/yc" iam create-token)
  export TF_VAR_folder_id=$YC_FOLDER_ID
  export TF_VAR_cloud_id=$YC_CLOUD_ID
  export TF_VAR_yc_service_account=$YC_SERVICE_ACCOUNT


  "${APP_HOME}dist/terraform/terraform" -chdir="${APP_HOME}diploma/infrastructure/terraform" init
  if [[ $DESTROY_CLUSTER == 1 ]]; then
    "${APP_HOME}dist/terraform/terraform" -chdir="${APP_HOME}diploma/infrastructure/terraform" destroy

    echo ""
    if [[ $? -eq 0 ]]; then
      echo "K8s cluster was destroyed."
    fi
    exit $?
  fi

  "${APP_HOME}dist/terraform/terraform" -chdir="${APP_HOME}diploma/infrastructure/terraform" apply

  if [[ ! $? -eq 0 ]]; then
    echo "Please provide your account name below."
    echo "Teraform error. Exiting..."

    exit $?
  fi

  echo "Creating config of terraform s3 backup state..."
  if [[ $( grep "#s3_private_block_configuration" "${APP_HOME}diploma/infrastructure/terraform/versions.tf" ) ]]; then 
    new_versions_file_configuration="${APP_HOME}diploma/infrastructure/terraform/versions.s3"; \
      while IFS= read -r line; do \
        if [[ ! $line == "" ]]; then \
          if [[ ! $line == '#s3_private_block_configuration' ]]; then \
            echo -e "${line}" >> $new_versions_file_configuration; \
            else ${APP_HOME}dist/terraform/terraform -chdir=${APP_HOME}diploma/infrastructure/terraform output -raw private_state_storage_terraform_full_access_info >> $new_versions_file_configuration; \
          fi; \
        fi; \
      done < "${APP_HOME}diploma/infrastructure/terraform/versions.tf" && \
        mv -f "$new_versions_file_configuration" "${APP_HOME}diploma/infrastructure/terraform/versions.tf"
  fi

  "${APP_HOME}dist/terraform/terraform" -chdir="${APP_HOME}diploma/infrastructure/terraform" init

  echo "Waiting for the cluster is online..."
  sleep 30

  echo ""
  echo "Creating access for Kubernetes CLI (kubeconfig)..."
  echo "--------------------------------------------------"
  "${APP_HOME}dist/yandex-cloud/bin/yc" managed-kubernetes cluster get-credentials --id $("${APP_HOME}dist/terraform/terraform" -chdir="${APP_HOME}diploma/infrastructure/terraform" output -raw  cluster_id) --external --force
fi

echo ""
echo "Installing the ingress controller..."
echo "------------------------------------"
"${APP_HOME}dist/helm/helm" repo add ingress-nginx "https://kubernetes.github.io/ingress-nginx" && \
     "${APP_HOME}dist/helm/helm" repo update && \
     "${APP_HOME}dist/helm/helm" upgrade --timeout 360s --install ingress-nginx ingress-nginx/ingress-nginx

if [[ ! $? -eq 0 ]]; then
  echo "Ingress controller installation error. Please, try again later."
  echo "Exiting..."

  exit $?
fi

echo "Wait a little..."
sleep 10

echo ""
echo "Installing cert-manager..."
echo "-------------------------"
"${APP_HOME}dist/kubernetes/kubectl" apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.1/cert-manager.yaml && \
  echo "Waiting..." && "${APP_HOME}dist/kubernetes/kubectl" wait pod --all --for=condition=Ready -n cert-manager --timeout=300s && sleep 20 &&  \
  envsubst < "${APP_HOME}diploma/infrastructure/kubernetes/cert-manager.yaml" | "${APP_HOME}dist/kubernetes/kubectl" apply -f -

if [[ ! $? -eq 0 ]]; then
  echo "Cert-manager installation error. Please, try again later."
  echo "Exiting..."

  exit $?
fi

echo ""
echo "Installing monitoring application (prometheus)..."
echo "-------------------------------------------------"
"${APP_HOME}dist/helm/helm" upgrade --atomic --wait --timeout 360s --install --set external_url="prometheus.$FRONTEND_EXTERNAL_FQDN" prometheus "${APP_HOME}diploma/infrastructure/monitoring-tools/prometheus"

if [[ ! $? -eq 0 ]]; then
  echo "Prometheus installation error. Please, try again later."
  echo "Exiting..."

  exit $?
fi

echo ""
echo "Installing monitoring application (grafana)..."
echo "----------------------------------------------"
"${APP_HOME}dist/helm/helm" upgrade --atomic --wait --timeout 360s --install --set ingress.hosts[0]="grafana.$FRONTEND_EXTERNAL_FQDN" grafana "${APP_HOME}diploma/infrastructure/monitoring-tools/grafana"

if [[ ! $? -eq 0 ]]; then
  echo "Prometheus installation error. Please, try again later."
  echo "Exiting..."

  exit $?
fi


echo "Waiting for the services is fully online..."
sleep 10

echo ""
echo "Application installation..."
echo "==========================="

"${APP_HOME}dist/helm/helm" upgrade --install "dumplings-store" "${APP_HOME}diploma/infrastructure/kubernetes/dumplings-store-chart" \
                     --set "backend.image.Tag=$BACKEND_IMAGE_VERSION" \
                     --set "frontend.image.Tag=$FRONTEND_IMAGE_VERSION" \
                     --set "global.repositoryUrl=${REPOSITORY_IMAGES_URL}" \
                     --set "global.k8sHostname=${FRONTEND_EXTERNAL_FQDN}" \
                     --set "global.tslStoreSecretName=${TLS_STORE_SECRET_NAME}" \
                     --set "backend.environmentConfig[0].name=PUBLIC_OBJECT_STORAGE_URL" \
                     --set "backend.environmentConfig[0].value=https://storage.yandexcloud.net/$PUBLIC_OBJECT_STORAGE_NAME/" \
                     --wait \
                     --timeout 300s \
                     --atomic

if [[ ! $? -eq 0 ]]; then
  echo "Error. Please wait for a minute and do repeat."
  echo "Exiting..."

  exit $?
fi

if [[ ! $NO_INFRASTRUCTURE -eq 1 ]]; then
  echo ""
  echo "Syncing object storage..."
  echo "
  [yandex-s3-dumplings-store]
  type = s3
  provider = AWS
  access_key_id = $( ${APP_HOME}dist/terraform/terraform -chdir=${APP_HOME}diploma/infrastructure/terraform output -raw bucket_access_id )
  secret_access_key = $( ${APP_HOME}dist/terraform/terraform -chdir=${APP_HOME}diploma/infrastructure/terraform output -raw bucket_access_key )
  endpoint = storage.yandexcloud.net

  [local-dumplings-store]
  type = alias
  remote = ${APP_HOME}diploma/frontend/img/" >> ~/.config/rclone/rclone.conf 
  "${APP_HOME}dist/rclone/rclone" sync local-dumplings-store: yandex-s3-dumplings-store:/$PUBLIC_OBJECT_STORAGE_NAME


  echo ""
  echo "Generating static kube-config file."
  echo "==================================="

  cluster_endpoint=$("${APP_HOME}dist/terraform/terraform" -chdir="${APP_HOME}diploma/infrastructure/terraform" output -raw cluster_endpoint)
  cluster_name=yc-managed-k8s-$("${APP_HOME}dist/terraform/terraform" -chdir="${APP_HOME}diploma/infrastructure/terraform" output -raw cluster_name)-$("${APP_HOME}dist/terraform/terraform" -chdir="${APP_HOME}diploma/infrastructure/terraform" output -raw cluster_id)
  cluster_cert=$("${APP_HOME}dist/terraform/terraform" -chdir="${APP_HOME}diploma/infrastructure/terraform" output -raw cluster_cert)

  cluster_id=$("${APP_HOME}dist/terraform/terraform" -chdir="${APP_HOME}diploma/infrastructure/terraform" output -raw cluster_id) && \
    "${APP_HOME}dist/yandex-cloud/bin/yc" managed-kubernetes cluster get --id $cluster_id --format json | \
    jq -r .master.master_auth.cluster_ca_certificate | awk '{gsub(/\\n/,"\n")}1' > ${APP_HOME}cluster_id_ca.pem && \
    envsubst < "${APP_HOME}diploma/infrastructure/kubernetes/yc-sa-create-token.yaml" | kubectl apply -f - && rm ${APP_HOME}cluster_id_ca.pem

  sa_token=$( "${APP_HOME}dist/kubernetes/kubectl" -n kube-system get secret "$( "${APP_HOME}dist/kubernetes/kubectl" -n kube-system get secret | grep $CLUSTER_ADMIN-token | awk '{print $1}')" -o json | jq -r .data.token | base64 -d)

  k8s_config=$(cat <<SETVAR
---
apiVersion: v1
kind: Config
clusters:
- cluster:
    server: $cluster_endpoint
    certificate-authority-data: $cluster_cert
  name: $cluster_name
current-context: 
users:
- name: $CLUSTER_ADMIN
  user:
    token: $sa_token
contexts:
- context:
    cluster: $cluster_name
    user: $CLUSTER_ADMIN
  name: default@$cluster_name
current-context: default@$cluster_name
SETVAR
)

  echo ""
  echo "#external_access_config"
  echo "-----------------------"
  echo -e "${k8s_config}"
  echo ""
  echo "#external_access_config_base64"
  echo -e $( echo -e "${k8s_config}" | base64 )
fi

echo "Wait a little..."
sleep 10

echo ""
echo "Done."
echo "====="
echo -e "You can access to your application at by the url \nhttps://$FRONTEND_EXTERNAL_FQDN \nor by external ip below."
"${APP_HOME}dist/kubernetes/kubectl" get ingress tls-frontend-ingress

echo -e "\nApplication monitoring URLs:"
echo -e "Prometheus: http://prometheus.$FRONTEND_EXTERNAL_FQDN"
echo -e "Grafana: http://grafana.$FRONTEND_EXTERNAL_FQDN (default access: admin/admin)"

