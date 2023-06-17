# Multispace (tfe_workspace_run) TFC Examples

Accompaniment to blog post LINK TODO

## To Provision...


Beyond that, it should mostly just work.
(And please raise an issue if it does not!)

There are a few other dependencies:
* Your TFC org must have VCS set up within it to create new workspaces linked to GitHub orgs. The config here assumes exactly one GitHub VCS provider.
* The bootstrap workspace runs locally. You'll need to `terraform login` to get that working.
* There may be other dependencies I've missed. I'll update if I find any.

You'll probably want to fork this repo, and replace `fancycorp` (my org) with your org name.

At the very least, you'll want to set the value of the `tfc_org` variable in `0-bootstrap`

In `0-bootstrap`, run `terraform apply`. That will create a few projects, some workspaces, and a few other resources.

There are no external dependencies outside of Terraform Cloud, to make things simple. You can totally expand upon these ideas to do things with other Providers.

## Example 1: Run Triggers

This is the example of what things look like with Run Triggers.

They're very simple, and work well for many use-cases, but they don't work for all.

## Example 2: Workspace Manager

This is an example where we create a workspace, some variables, and other things, then kick off an apply.
That part is very similar to Run Triggers.

Where it differs is on the Destroy, where the downstream workspace gets destroyed first before it's deleted.

The blog post mentions destroy-only examples, and the bootstrap workspace in this repo has an example of this, which it uses to manage this "Workspace Manager"

## Example 3: Chain

An example of a chain of workspaces which must run in a particular order, and an orchestrator workspace which handles that ordering.

## Example 4: Mesh

A more complex example, with 3 upstream workspaces which must run before any of three downstream workspaces run.
