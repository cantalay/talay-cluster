terraform {
  required_version = "~> 1.16.0"

  backend "kubernetes" {}

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.2.1"
    }
  }
}
