terraform {
  cloud {
    organization = "fancycorp"

    workspaces {
      tags = ["multispace:upstream-downstream"]
    }
  }

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }

    tfe = {
      source  = "hashicorp/tfe"
      version = ">= 0.45.0"
    }
  }
}

variable "upstream_workspaces" {
  type    = set(string)
  default = []
}

variable "tfc_org" {
  type = string
}

provider "tfe" {
  organization = var.tfc_org
}

data "tfe_outputs" "upstream" {
  for_each = var.upstream_workspaces

  workspace = each.key
}

output "upstream_random_pets" {
  value = flatten([
    for upstream in var.upstream_workspaces :
    data.tfe_outputs.upstream[upstream].nonsensitive_values.all_random_pets
  ])
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
  value = flatten(
    concat(
      [
        for upstream in var.upstream_workspaces :
        data.tfe_outputs.upstream[upstream].nonsensitive_values.all_random_pets
      ],
      [
        random_pet.example.id
      ]
    )
  )
}
