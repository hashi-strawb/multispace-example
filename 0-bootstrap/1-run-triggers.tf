resource "tfe_project" "run-triggers" {
  name = "1 - Run Triggers"
}



resource "tfe_workspace" "run-triggers-upstream-a" {
  name           = "1-upstream-a"
  auto_apply     = true
  queue_all_runs = false
  force_delete   = true
  project_id     = tfe_project.run-triggers.id

  working_directory = "1-run-triggers/upstream"

  vcs_repo {
    identifier         = "hashi-strawb/multispace-example"
    ingress_submodules = false
    oauth_token_id     = var.oauth_token_id
  }

  remote_state_consumer_ids = [
    tfe_workspace.run-triggers-downstream.id
  ]
}


resource "tfe_workspace" "run-triggers-upstream-b" {
  name           = "1-upstream-b"
  auto_apply     = true
  queue_all_runs = false
  force_delete   = true
  project_id     = tfe_project.run-triggers.id

  working_directory = "1-run-triggers/upstream"

  vcs_repo {
    identifier         = "hashi-strawb/multispace-example"
    ingress_submodules = false
    oauth_token_id     = var.oauth_token_id
  }

  remote_state_consumer_ids = [
    tfe_workspace.run-triggers-downstream.id
  ]
}


resource "tfe_workspace" "run-triggers-downstream" {
  name           = "1-downstream"
  auto_apply     = true
  queue_all_runs = false
  force_delete   = true
  project_id     = tfe_project.run-triggers.id

  working_directory = "1-run-triggers/downstream"

  vcs_repo {
    identifier         = "hashi-strawb/multispace-example"
    ingress_submodules = false
    oauth_token_id     = var.oauth_token_id
  }
}

resource "tfe_run_trigger" "run-triggers-upstream-a-downstream" {
  sourceable_id = tfe_workspace.run-triggers-upstream-a.id
  workspace_id  = tfe_workspace.run-triggers-downstream.id
}

resource "tfe_run_trigger" "run-triggers-upstream-b-downstream" {
  sourceable_id = tfe_workspace.run-triggers-upstream-b.id
  workspace_id  = tfe_workspace.run-triggers-downstream.id
}


resource "tfe_variable" "run-triggers-downstream-upstreams" {
  category = "terraform"
  hcl      = true
  key      = "upstream_workspaces"
  value = jsonencode([
    "1-upstream-a",
    "1-upstream-b",
  ])
  workspace_id = tfe_workspace.run-triggers-downstream.id
}

resource "tfe_variable" "run-triggers-downstream-tfc_org" {
  category     = "terraform"
  key          = "tfc_org"
  value        = var.tfc_org
  workspace_id = tfe_workspace.run-triggers-downstream.id
}
