#!/usr/bin/env bash

. .demo-magic.sh
clear

pe 'gcloud beta game servers clusters delete usc1-green --realm united-states --no-dry-run'
pe 'gcloud beta game servers clusters delete usc1-blue --realm united-states --no-dry-run'

pe 'helm --kube-context green delete agones -n agones-system'
pe 'helm --kube-context blue delete agones -n agones-system'

pe 'helm --kube-context green delete cert-manager -n cert-manager'
pe 'helm --kube-context blue delete cert-manager -n cert-manager'

pe 'cd terraform; terraform destroy'
cd ..
