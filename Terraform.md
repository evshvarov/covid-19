## Prerequisites to run Terraform

It's better to read [this article](https://community.intersystems.com/post/automating-gke-creation-circleci-builds) at first. But in short:

#### Create Service Account for Terraform
```
$ gcloud init
$ cd <root_repo_dir>
$ mkdir terraform; cd terraform
$ gcloud iam service-accounts create terraform --description "Terraform" --display-name "terraform"
```

#### Add a few roles to it
```
$ gcloud projects add-iam-policy-binding <PROJECT_ID> \
  --member serviceAccount:terraform@<PROJECT_ID>.iam.gserviceaccount.com \
  --role roles/container.admin

$ gcloud projects add-iam-policy-binding <PROJECT_ID> \
  --member serviceAccount:terraform@<PROJECT_ID>.iam.gserviceaccount.com \
  --role roles/iam.serviceAccountUser

$ gcloud projects add-iam-policy-binding <PROJECT_ID> \
  --member serviceAccount:terraform@<PROJECT_ID>.iam.gserviceaccount.com \
  --role roles/compute.viewer

$ gcloud projects add-iam-policy-binding <PROJECT_ID> \
  --member serviceAccount:terraform@<PROJECT_ID>.iam.gserviceaccount.com \
  --role roles/storage.admin

$ gcloud iam service-accounts keys create account.json \
  --iam-account terraform@<PROJECT_ID>.iam.gserviceaccount.com
```
Note that the last entry creates your account.json file. Be sure to keep this file secret.

#### Enable service "Kubernetes Engine"
```
$ gcloud projects list
$ gcloud config set project <PROJECT_ID>
$ gcloud services list --available | grep 'Kubernetes Engine'
$ gcloud services enable container.googleapis.com
$ gcloud services list --enabled | grep 'Kubernetes Engine'
container.googleapis.com Kubernetes Engine API
```

#### Create Google bucket to store Terraform state
Use the name of your bucket instead of the placeholder <BUCKET_NAME>. Before bucket creation let’s check if <BUCKET_NAME> is available as it has to be unique across all GCP:
```
$ gsutil acl get gs://<BUCKET_NAME>
```

Good answer:
```
BucketNotFoundException: 404 gs://<BUCKET_NAME> bucket does not exist
```

"Busy" answer means you have to choose another name:
```
AccessDeniedException: 403 <YOUR_ACCOUNT> does not have storage.buckets.get access to <BUCKET_NAME>
```

Let’s also enable versioning:
```
$ gsutil mb -l EU gs://<BUCKET_NAME>
$ gsutil versioning get gs://<BUCKET_NAME>
gs://<BUCKET_NAME>: Suspended

$ gsutil versioning set on gs://<BUCKET_NAME>

$ gsutil versioning get gs://<BUCKET_NAME>
gs://<BUCKET_NAME>: Enabled
```

#### Use your values instead of placeholders in main.tf file
* <PROJECT_ID> - GCP project ID. Example: `possible-symbol-254507`
* <BUCKET_NAME> - Storage for Terraform state/lock—should be unique. Example: `github-gke-terraform-demo`
* \<REGION\> - Region where resources will be created. Example: `europe-west1`
* \<LOCATION\> - Zone where resources will be created. Example: `europe-west1-b`
* <CLUSTER_NAME> - GKE cluster name. Example: `dev-cluster`
* <NODES_POOL_NAME> - GKE worker nodes pool name. Example: `dev-cluster-node-pool`
