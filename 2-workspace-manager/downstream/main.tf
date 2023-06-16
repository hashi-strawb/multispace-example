terraform {
  cloud {
    organization = "fancycorp"

    workspaces {
      tags = ["multispace:downstream", "example:2-workspace-manager"]
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
  depends_on = [time_sleep.wait_30_seconds]

  length    = 1
  prefix    = terraform.workspace
  separator = ":"
}

output "random_pet" {
  value = random_pet.example.id
}

