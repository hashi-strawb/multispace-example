terraform {
  cloud {
    organization = "fancycorp"

    workspaces {
      tags = ["multispace:upstream"]
    }
  }

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }
  }
}

resource "random_pet" "example" {
  length    = 1
  prefix    = terraform.workspace
  separator = ":"
}

output "random_pet" {
  value = random_pet.example.id
}

