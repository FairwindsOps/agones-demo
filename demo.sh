#!/usr/bin/env bash

########################
# include the magic
########################
. .demo-magic.sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Terraform
p '# Run the Terraform'
pei 'cd terraform && terraform init && terraform apply -auto-approve'

# Istio
p '# Enable Istio on both clusters'
pei 'gcloud beta container clusters update agones-usc1-green --update-addons=Istio=ENABLED --istio-config=auth=MTLS_PERMISSIVE --zone us-central1 --async'
pei 'gcloud beta container clusters update agones-usc1-blue --update-addons=Istio=ENABLED --istio-config=auth=MTLS_PERMISSIVE --zone us-central1 --async'

# Kubeconfigs
p '# Get access to the clusters and rename the contexts to more usable'
export KUBECONFIG="${DIR}/kubeconfig"
pei 'gcloud container clusters get-credentials agones-usc1-green --region us-central1'
pei 'kubectl config rename-context gke_agones-demo-280722_us-central1_agones-usc1-green green'

pei 'gcloud container clusters get-credentials agones-usc1-blue --region us-central1'
pei 'kubectl config rename-context gke_agones-demo-280722_us-central1_agones-usc1-blue blue'

pei 'kubectl config get-contexts'

# Install Agones and Cert Manager using Reckoner in each cluster
p '# Install Agones and Cert-Manager using Reckoner in each cluster'
COURSE_FILE='${DIR}/resources/course.yaml'
pei "kubectl config use-context blue; reckoner plot ${COURSE_FILE} -a"
pei "kubectl config use-context green; reckoner plot ${COURSE_FILE} -a"

