terraform {
  backend "gcs" {
    bucket = "jbcalling-tf-state"
    prefix = "terraform/state"
  }
}
