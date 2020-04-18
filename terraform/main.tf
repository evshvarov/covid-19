/*
  It's a Terraform file from article https://community.intersystems.com/post/automating-gke-creation-circleci-builds
  Several placeholders are used here. See below their meaning:

  ---------------------------------------------------------------------------------------------------
  Placeholder       | Meaning                                           | Example
  ---------------------------------------------------------------------------------------------------
  <PROJECT_ID>      | GCP project ID                                    | possible-symbol-254507  
  <BUCKET_NAME>     | Storage for Terraform state/lock—should be unique | circleci-gke-terraform-demo
  <REGION>          | Region where resources will be created            | europe-west1
  <LOCATION>        | Zone where resources will be created              | europe-west1-b
  <CLUSTER_NAME>    | GKE cluster name                                  | dev-cluster
  <NODES_POOL_NAME> | GKE worker nodes pool name                        | dev-cluster-node-pool 
  ---------------------------------------------------------------------------------------------------
*/

/*
  Also, please note that Terraform uses remote bucket. This bucket should be initially created
  The following commands could be useful for that:

  Check <BUCKET_NAME> availability:
  $ gsutil acl get gs://<BUCKET_NAME>

  Good answer:
  BucketNotFoundException: 404 gs://<BUCKET_NAME> bucket does not exist

  "Busy" answer:
  AccessDeniedException: 403 <YOUR_ACCOUNT> does not have storage.buckets.get access to <BUCKET_NAME>

  Create bucket with versioning:
  $ gsutil mb -l EU gs://<BUCKET_NAME>
  
  $ gsutil versioning get gs://<BUCKET_NAME>
  gs://<BUCKET_NAME>: Suspended

  $ gsutil versioning set on gs://<BUCKET_NAME>

  $ gsutil versioning get gs://<BUCKET_NAME>
  gs://<BUCKET_NAME>: Enabled

*/

terraform {
  required_version = "~> 0.12"
  backend "gcs" {
    bucket      = "covid19-analytics"
    prefix      = "terraform/state"
  }
}

provider "google" {
  project     = "zpm-package-manager"
  region      = "europe-west1"
}

resource "google_container_cluster" "gke-cluster" {
  name                     = "covid19-cluster"
  location                 = "europe-west1-b"
  remove_default_node_pool = true
  # In regional cluster (location is region, not zone) this is a number of nodes per zone
  initial_node_count = 1
}

resource "google_container_node_pool" "preemptible_node_pool" {
  name     = "covid19-cluster-node-pool"
  location = "europe-west1-b"
  cluster  = google_container_cluster.gke-cluster.name
  # In regional cluster (location is region, not zone) this is a number of nodes per zone
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "n1-standard-1"
    oauth_scopes = [
      "storage-ro",
      "logging-write",
      "monitoring"
    ]
  }
}

