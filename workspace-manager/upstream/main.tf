terraform {
  cloud {
    organization = "fancycorp"

    workspaces {
      tags = ["multispace:upstream", "example:2-workspace-manager"]
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

  working_directory = "upstream-downstream/downstream"

  vcs_repo {
    identifier         = "hashi-strawb/multispace-example"
    ingress_submodules = false
    oauth_token_id     = data.tfe_oauth_client.client.oauth_token_id
  }

  tag_names = ["multispace:downstream", "example:2-workspace-manager"]
}

resource "tfe_workspace_run" "downstream" {
  workspace_id = tfe_workspace.downstream.id

  # depends_on = creds and other dependencies go here
  # for a real example, see ../0-bootstrap/2-workspace-manager.tf
  # (that example is a destroy-only example too, for some variety)

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
