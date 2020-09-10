# Agones Demo

This repository contains the code necessary to run my Kubevirtual demo of Agones and GCGS (Google Cloud Game Servers).

## What this Demo Does

### Using Terraform

1. Build two GKE Clusters, green and blue, in the us-central1 region. Each has their own network.
1. Create firewall rules for the gameservers to be accessible
1. Create a GCGS realm named `united-states`
1. Create a GCGS Deployment, Config (with autoscaling), and Rollout for supertuxkart

### Using Reckoner

1. Install Agones and cert-manager
1. Create a self-signed cluster issuer in each cluster
1. Create the `gameserver` namespace

### Bash (contained in demo script)

1. Setup allocation services with cert issued by cert-manager
1. Connect clusters to GCGS Realm using gcloud commands
1. Deploy the Fleet of Gameservers (happens automatically when clusters are connected to the realm since the deployment, config, and rollout were already there)
1. Generate a client cert and add it to the allow list for each allocator
1. Allocate a gameserver for use by the client in each cluster
1. Allocate a gameserver using multi-cluster allocation

### Manual

1. Connect to the gameserver, start game, end game

## Using this Repository

### Required Tools

* [Terraform](https://www.terraform.io/) - at least version `0.12.29`
* [reckoner](https://github.com/fairwindsops/reckoner) - at least version `4.2.0`
* [gcloud cli](https://cloud.google.com/sdk/gcloud/)
* [jq](https://stedolan.github.io/jq/)
* `openssl` for generating client certificates
* [agones-allocator-client](https://github.com/fairwindsops/agones-allocator-client)
* `kubectl`

_NOTE: Some of these tools can be installed via [asdf](https://asdf-vm.com/) and I have included a .tool-versions file in this repo_

### Running the Demo Yourself

First, you'll want to change the GCP project reference to whatever GCP project you are planning to use. You can grep for `agones-demo-280722` to find the references.

Then just run `./demo.sh`.  This repo uses [demo-magic](https://github.com/paxtonhare/demo-magic), so you can pass some flags to it if the default behavior isn't what you want.

### Teardown

There is another demo script called `teardown.sh` that you can run. This will de-register the clusters, delete the helm releases, and then run a `terraform destroy`
