provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

provider "http" {}
provider "kubernetes" {
  config_path = "~/.kube/config" # Chemin vers votre fichier de configuration kubeconfig
}