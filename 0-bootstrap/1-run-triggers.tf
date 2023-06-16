import {
  id = "prj-FhdgNGo4ceoBc82z"
  to = tfe_project.run-triggers
}
resource "tfe_project" "run-triggers" {
  name = "1 - Run Triggers"
}



import {
  id = "fancycorp/1-upstream-a"
  to = tfe_workspace.run-triggers-upstream-a
}
resource "tfe_workspace" "run-triggers-upstream-a" {
  name           = "1-upstream-a"
  auto_apply     = true
  queue_all_runs = false

  working_directory = "1-run-triggers/upstream"

  vcs_repo {
    identifier         = "hashi-strawb/multispace-example"
    ingress_submodules = false
    oauth_token_id     = var.oauth_token_id
  }
}


import {
  id = "fancycorp/1-upstream-b"
  to = tfe_workspace.run-triggers-upstream-b
}
resource "tfe_workspace" "run-triggers-upstream-b" {
  name           = "1-upstream-b"
  auto_apply     = true
  queue_all_runs = false

  working_directory = "1-run-triggers/upstream"

  vcs_repo {
    identifier         = "hashi-strawb/multispace-example"
    ingress_submodules = false
    oauth_token_id     = var.oauth_token_id
  }
}


import {
  id = "fancycorp/1-downstream"
  to = tfe_workspace.run-triggers-downstream
}
resource "tfe_workspace" "run-triggers-downstream" {
  name           = "1-downstream"
  auto_apply     = true
  queue_all_runs = false

  working_directory = "1-run-triggers/downstream"

  vcs_repo {
    identifier         = "hashi-strawb/multispace-example"
    ingress_submodules = false
    oauth_token_id     = var.oauth_token_id
  }
}

import {
  id = "rt-85EfZSGVPPkSz6Hx"
  to = tfe_run_trigger.run-triggers-upstream-a-downstream
}
resource "tfe_run_trigger" "run-triggers-upstream-a-downstream" {
  sourceable_id = tfe_workspace.run-triggers-upstream-a.id
  workspace_id  = tfe_workspace.run-triggers-downstream.id
}

import {
  id = "rt-LpBykM5jJkwDTKjr"
  to = tfe_run_trigger.run-triggers-upstream-b-downstream
}
resource "tfe_run_trigger" "run-triggers-upstream-b-downstream" {
  sourceable_id = tfe_workspace.run-triggers-upstream-b.id
  workspace_id  = tfe_workspace.run-triggers-downstream.id
}


import {
  id = "fancycorp/1-downstream/var-7pdiEFaa4VWG7ZkM"
  to = tfe_variable.run-triggers-downstream-upstreams
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
