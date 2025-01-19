
variable "credentials" {
  description = "Project Credentials"
  default = "./keys/my_creds.json"
}

variable "project" {
  description = "Project"
  default = "midyear-spot-447118-j6"
}



variable "location" {
  description = "Project Location"
  default = "US"
}

variable "region" {
  description = "region"
  default = "us-central1"
}


variable "bq_dataset_name" {
  description = "My BigQuery Dataset Name"
  default = "demo_dataset"
}

variable "gcs_storage_class" {
  description = "Bucket Storage Class"
  default = "demo_dataset"
}

variable "gcs_bucket_name" {
  description = "My Storage Bucket Name"
  default = "midyear-spot-447118-j6-terra-bucket"
}