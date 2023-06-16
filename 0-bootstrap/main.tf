terraform {
  cloud {
    organization = "fancycorp"

    workspaces {
      name = "multispace-blog"
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
