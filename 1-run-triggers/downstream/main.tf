terraform {
  cloud {
    organization = "fancycorp"

    workspaces {
      tags = ["multispace:downstream"]
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
  default = ["1-upstream"]
}

variable "tfc_org" {
  default = "fancycorp"
}

data "tfe_outputs" "upstream" {
  for_each = var.upstream_workspaces

  organization = var.tfc_org
  workspace    = each.key
}

output "upstream_random_pets" {
  value = [
    for upstream in var.upstream_workspaces :
    data.tfe_outputs.upstream[upstream].nonsensitive_values.random_pet
  ]
}

resource "random_pet" "example" {
  length    = 1
  prefix    = terraform.workspace
  separator = ":"
}

output "downstream_random_pet" {
  value = random_pet.example.id
}

output "all_random_pets" {
  value = concat(
    [
      for upstream in var.upstream_workspaces :
      data.tfe_outputs.upstream[upstream].nonsensitive_values.random_pet
    ],
    [
      random_pet.example.id
    ]
  )
}
