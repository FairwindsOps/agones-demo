terraform {
  required_version = ">=0.12.29"
}

provider "google" {
  version = ">=3.39.0"
  project = "agones-demo-280722"
  region  = "us-central1"
}
