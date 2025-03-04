#!/usr/bin/env bash

########################
# include the magic
########################
. .demo-magic.sh
clear
REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Terraform
p '# Run the Terraform'
pe 'cd terraform; terraform init && terraform apply -auto-approve || terraform apply -auto-approve; cd ..'

# Istio
p '# Enable Istio on both clusters'
pe 'gcloud beta container clusters update agones-usc1-green --update-addons=Istio=ENABLED --istio-config=auth=MTLS_PERMISSIVE --zone us-central1 --async'
pe 'gcloud beta container clusters update agones-usc1-blue --update-addons=Istio=ENABLED --istio-config=auth=MTLS_PERMISSIVE --zone us-central1 --async'

# Kubeconfigs
p '# Get access to the clusters and rename the contexts to be more usable'
export KUBECONFIG="${REPO_DIR}/kubeconfig"
pe 'kubectl config delete-context green; gcloud container clusters get-credentials agones-usc1-green --region us-central1'
pe 'kubectl config rename-context gke_agones-demo-280722_us-central1_agones-usc1-green green'

pe 'gcloud container clusters get-credentials agones-usc1-blue --region us-central1'
pe 'kubectl config delete-context blue; kubectl config rename-context gke_agones-demo-280722_us-central1_agones-usc1-blue blue'

pe 'kubectl config get-contexts'

# Install Agones and Cert Manager using Reckoner in each cluster
p '# Install Agones and Cert-Manager using Reckoner in each cluster'
COURSE_FILE='${REPO_DIR}/resources/course.yaml'
pe "kubectl config use-context blue; reckoner plot ${COURSE_FILE} -a"
pe "kubectl config use-context green; reckoner plot ${COURSE_FILE} -a"

pe "kubectl --context blue get po,svc -n agones-system"
pe "kubectl --context green get po,svc -n agones-system"

# Generate a client certificate and add it to the allowed list
p '# If needed, create a client cert. Then add that cert to the allow list in the Agones allocator'
pe 'if [ ! -f client.crt ]; then openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout client.key -out client.crt; fi'

# Configure allocator certificate
p "# Create a certificate from resources/cert-template.yaml by filling in the allocator's IP Address"
pe "kubectl --context green get services agones-allocator -n agones-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}'"
echo
GREEN_IP=$(kubectl --context green get services agones-allocator -n agones-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
pe 'cat $REPO_DIR/resources/cert-template.yaml | sed "s/__IP_ADDRESS__/${GREEN_IP}/g" | kubectl --context green apply -f -'
pe "kubectl --context green get secret allocator-tls -n agones-system -ojsonpath='{.data.ca\.crt}' | base64 -d > ca-green.crt"
PATCH="{\"data\": {\"tls-ca.crt\": \"$(cat ca-green.crt | base64)\"}}"
pe 'echo $PATCH | jq .'
pe 'kubectl -n agones-system --context green patch secret allocator-tls-ca --type merge -p "$PATCH"'

pe "kubectl --context blue get services agones-allocator -n agones-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}'"
echo
BLUE_IP=$(kubectl --context blue get services agones-allocator -n agones-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
pe 'cat $REPO_DIR/resources/cert-template.yaml | sed "s/__IP_ADDRESS__/${BLUE_IP}/g" | kubectl --context blue apply -f -'
pe "kubectl --context blue get secret allocator-tls -n agones-system -ojsonpath='{.data.ca\.crt}' | base64 -d > ca-blue.crt"
PATCH="{\"data\": {\"tls-ca.crt\": \"$(cat ca-blue.crt | base64)\"}}"
pe 'echo $PATCH | jq .'
pe 'kubectl -n agones-system --context blue patch secret allocator-tls-ca --type merge -p "$PATCH"'

# Allow the client
p '# Now we add the client cert to the allowed list of client certs in the allocator by patching the allocator-client-ca secret'
PATCH="{\"data\": {\"client.crt\": \"$(cat client.crt | base64)\"}}"
pe 'echo $PATCH | jq .'
pe 'kubectl --context blue patch secret allocator-client-ca -n agones-system --type merge -p "${PATCH}"'
pe 'kubectl --context green patch secret allocator-client-ca -n agones-system --type merge -p "${PATCH}"'

p '# Restart the allocators so that they pull in the new certificates'
pe 'kubectl --context green --namespace agones-system rollout restart deployment/agones-allocator'
pe 'kubectl --context blue --namespace agones-system rollout restart deployment/agones-allocator'

# Register the clusters (must happen after the allocator is setup so that multi cluster allocation works immediately)
p '# Register the clusters with the realm'
pe 'gcloud beta game servers clusters create usc1-blue --realm=united-states --gke-cluster="projects/agones-demo-280722/locations/us-central1/clusters/agones-usc1-blue" --namespace=gameserver --no-dry-run'
pe 'gcloud beta game servers clusters create usc1-green --realm=united-states --gke-cluster="projects/agones-demo-280722/locations/us-central1/clusters/agones-usc1-green" --namespace=gameserver --no-dry-run'

# Show existing gameservers that just got created
p '# Since we already deployed a fleet to the realm, we should start to see gameservers'
pe 'kubectl --context green get fleet,gameserver -n gameserver'
pe 'kubectl --context blue get fleet,gameserver -n gameserver'

# Make allocation requests
p '# Allocate a gameserver by  sending a request to the green allocator'
pe 'agones-allocator-client allocate --ca-cert ca-green.crt --key client.key --cert client.crt --hosts=$GREEN_IP:443  -v10 --namespace gameserver'
pe 'kubectl --context green get gs -n gameserver'

p '# Allocate a gameserver by  sending a request to the blue allocator'
pe 'agones-allocator-client allocate --ca-cert ca-blue.crt --key client.key --cert client.crt --hosts=$BLUE_IP:443  -v10 --namespace gameserver'
pe 'kubectl --context blue get gs -n gameserver'

p '# Now if we wait a few seconds and check again, we will see that autoscaling adds more gameservers'
pe 'kubectl --context green get gs -n gameserver'
pe 'kubectl --context blue get gs -n gameserver'


p '# If we pass the --multicluster flag, we should get allcoations from both clusters'
pe 'agones-allocator-client allocate --ca-cert ca-green.crt --key client.key --cert client.crt --hosts=$GREEN_IP:443  -v10 --namespace gameserver --multicluster'
pe 'kubectl --context green get gs -n gameserver'
pe 'kubectl --context blue get gs -n gameserver'
