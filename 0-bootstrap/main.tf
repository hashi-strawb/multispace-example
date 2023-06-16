terraform {
  cloud {
    organization = "fancycorp"

    workspaces {
      name = "multispace-blog"
    }
  }
}

provider "tfe" {
  organization = "fancycorp"
}

variable "oauth_token_id" {
  default = "ot-8hSCfUe8VncQMmW6"
}



