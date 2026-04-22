terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project     = local.project_id
  credentials = file("../credentials.json")
}

locals {
  credentials = jsondecode(file("../credentials.json"))
  project_id  = local.credentials.project_id
}
