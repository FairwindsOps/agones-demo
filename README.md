# Agones Demo

This repository contains the code necessary to run my Kubevirtual demo of Agones and GCGS (Google Cloud Game Servers).

## Steps

1. Build GKE Clusters (done pre-talk)
1. Installing Agones with Helm on the GKE clusters (1 min)
1. Setup allocation services (2 min)
1. Connect clusters to GCGS Realm using gcloud commands (1 min)
1. Deploy the Fleet of Gameservers (3 min)
1. Allocate a Gameserver for use by client (5 min)
1. Connect to the gameserver, start game, end game (5 min)

## Using this Repository

Required Tools:

* [Terraform](https://www.terraform.io/) - at least version `0.12.29`
* [Reckoner](https://github.com/fairwindsops/reckoner) - at least version `3.2.1

_NOTE: All of these tools can be installed via [asdf](https://asdf-vm.com/) and I have included a .tool-versions file in this repo_

