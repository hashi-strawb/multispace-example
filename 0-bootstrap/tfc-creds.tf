# use the owner team as a simple example
# in production, you would want fewer permissions

data "tfe_team" "owners" {
  name = "owners"
}

resource "tfe_team_token" "manage-workspaces" {
  team_id = data.tfe_team.owners.id
}

resource "tfe_variable_set" "tfc-creds" {
  name = "TFC: Workspace Manager"
}

resource "tfe_variable" "tfc-creds" {
  key             = "TFE_TOKEN"
  value           = tfe_team_token.manage-workspaces.token
  category        = "env"
  sensitive       = true
  variable_set_id = tfe_variable_set.tfc-creds.id
}

resource "tfe_workspace_variable_set" "tfc-creds" {
  for_each = toset([
    tfe_workspace.ws-manager-upstream.id,
  ])
  variable_set_id = tfe_variable_set.tfc-creds.id
  workspace_id    = each.key
}