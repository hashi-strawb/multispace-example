resource "tfe_project" "mesh" {
  name = "4 - Mesh"
}


locals {
  mesh_members = [
    "U1", "U2", "U3",
    "D1", "D2", "D3",
  ]

  mesh_upstreams = {
    "D1" = ["U1", "U2", "U3"],
    "D2" = ["U1", "U2", "U3"],
    "D3" = ["U1", "U2", "U3"],
  }
}


resource "tfe_workspace" "mesh" {
  for_each = toset(local.mesh_members)

  name           = "4-mesh-${each.key}"
  auto_apply     = true
  queue_all_runs = false
  force_delete   = true
  project_id     = tfe_project.mesh.id

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
    tfe_workspace.mesh[downstream_name].id
  ]
  */

  # So instead, to make for easier code...
  global_remote_state = true

  tag_names = ["multispace:upstream-downstream"]
}

resource "tfe_variable" "mesh-tfc_org" {
  for_each = toset(local.mesh_members)

  category     = "terraform"
  key          = "tfc_org"
  value        = var.tfc_org
  workspace_id = tfe_workspace.mesh[each.key].id
}


resource "tfe_variable" "mesh-upstreams" {
  for_each = local.mesh_upstreams

  category = "terraform"
  hcl      = true
  key      = "upstream_workspaces"

  value = jsonencode(
    [
      for upstream in each.value :
      "4-mesh-${upstream}"
    ]
  )

  workspace_id = tfe_workspace.mesh[each.key].id
}




# TODO: Orchestrator Workspace
