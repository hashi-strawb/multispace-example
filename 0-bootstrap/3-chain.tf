resource "tfe_project" "chain" {
  name = "3 - Chain"
}

locals {
  chain_members = [
    "A", "B", "C"
  ]

  chain_upstreams = {
    "B" = ["A"],
    "C" = ["B"],
  }
}


resource "tfe_workspace" "chain" {
  for_each = toset(local.chain_members)

  name           = "3-chain-${each.key}"
  auto_apply     = true
  queue_all_runs = false
  force_delete   = true
  project_id     = tfe_project.chain.id

  working_directory = "upstream-downstream"

  vcs_repo {
    identifier         = "hashi-strawb/multispace-example"
    ingress_submodules = false
    oauth_token_id     = data.tfe_oauth_client.client.oauth_token_id
  }

  # Ideally we'd do something like this... exposing the state only to its
  # direct downstream workspace. Unfortunately, we hit this issue:
  # https://github.com/hashicorp/terraform-provider-tfe/issues/331
  /*
  remote_state_consumer_ids = [
    for downstream_name in each.value :
    tfe_workspace.chain[downstream_name].id
  ]
  */

  # So instead, to make for easier code...
  global_remote_state = true

  tag_names = ["multispace:upstream-downstream"]
}

resource "tfe_variable" "chain-tfc_org" {
  for_each = toset(local.chain_members)

  category     = "terraform"
  key          = "tfc_org"
  value        = var.tfc_org
  workspace_id = tfe_workspace.chain[each.key].id
}


resource "tfe_variable" "chain-upstreams" {
  for_each = local.chain_upstreams

  category = "terraform"
  hcl      = true
  key      = "upstream_workspaces"

  value = jsonencode(
    [
      for upstream in each.value :
      "3-chain-${upstream}"
    ]
  )

  workspace_id = tfe_workspace.chain[each.key].id
}



#
# Runner Workspace
#

resource "tfe_workspace" "chain-runner" {
  name           = "3-chain-runner"
  auto_apply     = true
  queue_all_runs = false
  force_delete   = true
  project_id     = tfe_project.chain.id

  tag_names = ["multispace:chain-runner"]

  working_directory = "chain-runner"

  vcs_repo {
    identifier         = "hashi-strawb/multispace-example"
    ingress_submodules = false
    oauth_token_id     = data.tfe_oauth_client.client.oauth_token_id
  }
}

resource "tfe_variable" "chain-runner-tfc_org" {
  category     = "terraform"
  key          = "tfc_org"
  value        = var.tfc_org
  workspace_id = tfe_workspace.chain-runner.id
}
