module "network_agones_usc1_green" {
  source = "git@github.com:FairwindsOps/terraform-gcp-vpc-native.git//default?ref=default-v2.2.1"

  // base network parameters
  network_name    = local.network_name_green
  subnetwork_name = "green-nodes"
  region          = local.region

  //specify the staging subnetwork primary and secondary CIDRs for IP aliasing
  subnetwork_range    = "10.57.0.0/16"
  subnetwork_pods     = "10.58.0.0/16"
  subnetwork_services = "10.59.0.0/16"
}

# Ref: https://github.com/FairwindsOps/terraform-gcp-vpc-native
module "cluster_agones_usc1_green" {
  # Change the ref below to use a vX.Y.Z release instead of master.
  source = "git@github.com:/FairwindsOps/terraform-gke//vpc-native?ref=vpc-native-v1.2.0"

  name                             = "agones-usc1-green"
  region                           = local.region
  project                          = local.project
  kubernetes_version               = local.kubernetes_version
  network_name                     = local.network_name_green
  nodes_subnetwork_name            = module.network_agones_usc1_green.subnetwork
  pods_secondary_ip_range_name     = module.network_agones_usc1_green.gke_pods_1
  services_secondary_ip_range_name = module.network_agones_usc1_green.gke_services_1

  master_authorized_network_cidrs = [
    {
      # This is the module default, but demonstrates specifying this input.
      cidr_block   = "0.0.0.0/0"
      display_name = "from the Internet"
    },
  ]
}

module "node_pool_agones_usc1_green" {
  source = "git@github.com:/FairwindsOps/terraform-gke//node_pool?ref=node-pool-v3.1.0"

  name             = "node-pool-1"
  region           = module.cluster_agones_usc1_green.region
  gke_cluster_name = module.cluster_agones_usc1_green.name
  machine_type     = "n1-standard-4"
  min_node_count   = "1"
  max_node_count   = "5"
  node_tags        = ["game-server"]

  # Match the Kubernetes version from the GKE cluster!
  kubernetes_version = module.cluster_agones_usc1_green.kubernetes_version
}
