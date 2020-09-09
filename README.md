# Agones Demo

This repository contains the code necessary to run my Kubevirtual demo of Agones and GCGS (Google Cloud Game Servers).

## Steps

1. Build GKE Clusters
1. Installing Agones with Helm on the GKE clusters
1. Setup allocation services
1. Connect clusters to GCGS Realm using gcloud commands
1. Deploy the Fleet of Gameservers
1. Allocate a Gameserver for use by client
1. Connect to the gameserver, start game, end game

## Using this Repository

Required Tools:

* [Terraform](https://www.terraform.io/) - at least version `0.12.29`
* [reckoner](https://github.com/fairwindsops/reckoner) - at least version `4.2.0`
* [gcloud cli](https://cloud.google.com/sdk/gcloud/)
* [jq](https://stedolan.github.io/jq/)
* `openssl` for generating client certificates
* [agones-allocator-client](https://github.com/fairwindsops/agones-allocator-client)
* `kubectl`

_NOTE: Some of these tools can be installed via [asdf](https://asdf-vm.com/) and I have included a .tool-versions file in this repo_
