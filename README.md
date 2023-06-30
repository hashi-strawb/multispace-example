# Multispace (tfe_workspace_run) TFC Examples

Accompaniment to blog post LINK TODO

## To Provision...

There are a few other dependencies:
* Your TFC org must have VCS set up within it to create new workspaces linked to GitHub orgs. The config here assumes
 exactly one GitHub VCS provider.
* The bootstrap workspace runs locally. You'll need to `terraform login` to get that working
 (there's no reason why you can't run the bootstrap workspace remotely Terraform Cloud too... there's just less to setup
 if you run it locally)
* There may be other dependencies I've missed. I'll update if I find any.

You'll probably want to fork this repo, and replace `fancycorp` (my org) with your org name.
Or at the very least, you'll want to set the value of the `tfc_org` variable in `0-bootstrap`

Beyond that, it should mostly just work. (And please raise an issue if it does not!)

In `0-bootstrap`, run `terraform apply`. That will create a few projects, some workspaces, and a few other resources.

There are no external dependencies outside of Terraform Cloud, to make things simple. You can totally expand upon these
ideas to do things with other Providers.

## Example 1: Run Triggers

This is the example of what things look like with Run Triggers.

They're very simple, and work well for many use-cases, but they don't work for all.

This particular example includes two Upstream workspaces and one Downstream. What you should see is that applying only
one of the Upstream workspaces will still trigger an apply on the Downstream. However, as the Downstream workspace
depends on both the Upstream workspaces, it will fail. After the apply on the second Upstream however, the Downstream
workspace should apply successfully.

## Example 2: Workspace Creator

This is an example where we create a workspace, some variables, and other things, then kick off an apply.
That last part is very similar to Run Triggers.

Where it differs is on the Destroy, where the downstream workspace gets destroyed first before it's deleted.

The blog post mentions destroy-only examples, and the bootstrap workspace in this repo has an example of this, which it
uses to manage this "Workspace Manager" workspace.

## Example 3: Chain

An example of a chain of workspaces which must run in a particular order, and an runner workspace which handles
that ordering.

Here you should see our Runner workspace trigger applies on each workspace in the chain in order. When it comes to
a destroy, the destroys should be triggered in reverse order.

## Example 4: Mesh

A more complex example, with 3 upstream workspaces which must run before any of three downstream workspaces run.

The Runner workspace will wait until all three Upstream workspaces are complete before triggering any Downstream
workspaces.

If you have enough Concurrency on your TFC org, TF will run an apply on three at once. To simulate what would happen
in the case that you're limited on Concurrency, you can add the following Environment Variable to the Runner
workspace:

```
TF_CLI_ARGS_apply="-parallelism=1"
```

This forces Terraform on the Runner workspace to only apply one resource at a time.
