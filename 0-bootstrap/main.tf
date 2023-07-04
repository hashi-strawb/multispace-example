terraform {
  required_providers {
    tfe = {
      source = "hashicorp/tfe"

      # Latest fixes for tfe_workspace_run
      version = ">= 0.46.0"
    }
  }
}

variable "tfc_org" {
  default = "fancycorp"
}

provider "tfe" {
  organization = var.tfc_org
}

data "tfe_oauth_client" "client" {
  organization     = var.tfc_org
  service_provider = "github"
}
