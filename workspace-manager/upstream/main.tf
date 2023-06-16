terraform {
  cloud {
    organization = "fancycorp"

    workspaces {
      tags = ["multispace:workspace-manager"]
    }
  }
}

variable "tfc_org" {
  type = string
}

provider "tfe" {
  organization = var.tfc_org
}

data "tfe_workspace" "self" {
  name = terraform.workspace
}
data "tfe_oauth_client" "client" {
  organization     = var.tfc_org
  service_provider = "github"
}

resource "tfe_workspace" "downstream" {
  name           = "2-downstream"
  auto_apply     = true
  queue_all_runs = false
  force_delete   = true
  project_id     = data.tfe_workspace.self.project_id

  working_directory = "upstream-downstream"

  vcs_repo {
    identifier         = "hashi-strawb/multispace-example"
    ingress_submodules = false
    oauth_token_id     = data.tfe_oauth_client.client.oauth_token_id
  }

  tag_names = ["multispace:upstream-downstream"]
}

resource "tfe_variable" "tfc_org" {
  category     = "terraform"
  key          = "tfc_org"
  value        = var.tfc_org
  workspace_id = tfe_workspace.downstream.id
}

resource "tfe_workspace_run" "downstream" {
  workspace_id = tfe_workspace.downstream.id

  depends_on = [tfe_variable.tfc_org]

  apply {
    # Fire and Forget
    wait_for_run = false
    # auto-apply
    manual_confirm = false
  }

  destroy {
    # Wait for destroy before doing anything else
    wait_for_run = true
    # auto-apply
    manual_confirm = false
  }
}
