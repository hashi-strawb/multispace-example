resource "tfe_project" "ws-creator" {
  name = "2 - Workspace Creator"
}
resource "tfe_workspace" "ws-creator-upstream" {
  name           = "2-creator"
  auto_apply     = true
  queue_all_runs = false

  # this workspace creates more workspaces
  # so don't just destroy it if it hasn't kicked off further destroys
  force_delete = false

  project_id = tfe_project.ws-creator.id

  working_directory = "workspace-creator"

  vcs_repo {
    identifier         = "hashi-strawb/multispace-example"
    ingress_submodules = false
    oauth_token_id     = data.tfe_oauth_client.client.oauth_token_id
  }
  tag_names = ["multispace:workspace-creator"]
}

resource "tfe_variable" "ws-creator-upstream-tfc_org" {
  category     = "terraform"
  key          = "tfc_org"
  value        = var.tfc_org
  workspace_id = tfe_workspace.ws-creator-upstream.id
}


resource "tfe_workspace_run" "destroy-ws-creator-upstream" {
  workspace_id = tfe_workspace.ws-creator-upstream.id

  depends_on = [
    # The workspace needs the tfc_org variable
    tfe_variable.ws-creator-upstream-tfc_org,

    # TFC creds need to exist, and be mapped to this workspace
    tfe_variable.tfc-creds,
    tfe_workspace_variable_set.tfc-creds,
  ]

  # So we can safely "terraform destroy" our bootstrap workspace...
  destroy {
    # Wait for destroy before doing anything else
    wait_for_run = true
    # auto-apply
    manual_confirm = false
  }
}
