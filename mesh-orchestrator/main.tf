terraform {
  cloud {
    organization = "fancycorp"

    workspaces {
      tags = ["multispace:orchestrator"]
    }
  }
}

variable "tfc_org" {
  type = string
}

provider "tfe" {
  organization = var.tfc_org
}


variable "upstream_workspaces" {
  type = set(string)

  default = [
    "4-mesh-U1",
    "4-mesh-U2",
    "4-mesh-U3",
  ]
}

data "tfe_workspace" "upstreams" {
  for_each = var.upstream_workspaces
  name     = each.key
}

variable "downstream_workspaces" {
  type = set(string)

  default = [
    "4-mesh-D1",
    "4-mesh-D2",
    "4-mesh-D3",
  ]
}

data "tfe_workspace" "downstreams" {
  for_each = var.downstream_workspaces
  name     = each.key
}



resource "tfe_workspace_run" "upstreams" {
  for_each = data.tfe_workspace.upstreams

  workspace_id = each.value.id

  apply {
    wait_for_run   = true
    manual_confirm = false
  }

  destroy {
    wait_for_run   = true
    manual_confirm = false
  }
}


resource "tfe_workspace_run" "downstreams" {
  for_each = data.tfe_workspace.downstreams

  workspace_id = each.value.id

  depends_on = [
    tfe_workspace_run.upstreams,
  ]

  apply {
    wait_for_run   = true
    manual_confirm = false
  }

  destroy {
    wait_for_run   = true
    manual_confirm = false
  }
}
