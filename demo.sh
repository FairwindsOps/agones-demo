#!/usr/bin/env bash

########################
# include the magic
########################
. .demo-magic.sh

REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Terraform
p '# Run the Terraform'
pei 'cd terraform; terraform init && terraform apply -auto-approve; cd ..'

# Istio
p '# Enable Istio on both clusters'
pei 'gcloud beta container clusters update agones-usc1-green --update-addons=Istio=ENABLED --istio-config=auth=MTLS_PERMISSIVE --zone us-central1 --async'
pei 'gcloud beta container clusters update agones-usc1-blue --update-addons=Istio=ENABLED --istio-config=auth=MTLS_PERMISSIVE --zone us-central1 --async'

# Kubeconfigs
p '# Get access to the clusters and rename the contexts to more usable'
export KUBECONFIG="${REPO_DIR}/kubeconfig"
pei 'gcloud container clusters get-credentials agones-usc1-green --region us-central1'
pei 'kubectl config rename-context gke_agones-demo-280722_us-central1_agones-usc1-green green'

pei 'gcloud container clusters get-credentials agones-usc1-blue --region us-central1'
pei 'kubectl config rename-context gke_agones-demo-280722_us-central1_agones-usc1-blue blue'

pei 'kubectl config get-contexts'

# Install Agones and Cert Manager using Reckoner in each cluster
p '# Install Agones and Cert-Manager using Reckoner in each cluster'
COURSE_FILE='${REPO_DIR}/resources/course.yaml'
pei "kubectl config use-context blue; reckoner plot ${COURSE_FILE} -a"
pei "kubectl config use-context green; reckoner plot ${COURSE_FILE} -a"

pei "kubectl --context blue get po,svc -n agones-system"
pei "kubectl --context green get po,svc -n agones-system"

# Register the clusters
p '# Register the clusters with the realm'
pei 'gcloud beta game servers clusters create usc1-blue --realm=united-states --gke-cluster="projects/agones-demo-280722/locations/us-central1/clusters/agones-usc1-blue" --namespace=gameserver --no-dry-run'
pei 'gcloud beta game servers clusters create usc1-green --realm=united-states --gke-cluster="projects/agones-demo-280722/locations/us-central1/clusters/agones-usc1-green" --namespace=gameserver --no-dry-run'

# Show existing gameservers
p '# Since we already deployed a fleet to the realm, we should start to see gameservers'
pei 'kubectl --context green get fleet,gameserver -n gameserver'
pei 'kubectl --context blue get fleet,gameserver -n gameserver'

# Generate a client certificate and add it to the allowed list
p '# If needed, create a client cert. Then add that cert to the allow list in the Agones allocator'
pei 'if [ ! -f client.crt ]; then openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout client.key -out client.crt; fi'
PATCH="{\"data\": {\"client.crt\": \"$(cat client.crt | base64)\"}}"
pei 'kubectl --context green patch secret allocator-tls-ca --type merge -p "$PATCH"'
pei 'kubectl --context blue patch secret allocator-tls-ca --type merge -p "$PATCH"'
