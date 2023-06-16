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

# Simulate this workspace doing a bunch of useful and interesting things
resource "time_sleep" "wait_30_seconds" {
  create_duration = "30s"
}

resource "random_pet" "example" {
  length    = 1
  prefix    = terraform.workspace
  separator = ":"
}

output "random_pet" {
  value = random_pet.example.id
}

output "all_random_pets" {
  value = [
    random_pet.example.id
  ]
}
