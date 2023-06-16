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

variable "oauth_token_id" {
  default = "ot-8hSCfUe8VncQMmW6"
}

provider "tfe" {
  organization = var.tfc_org
}
