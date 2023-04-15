locals {
  repository_name   = split("/", replace(var.github_repo_url, "/(.*github.com/)/", ""))[1]
  repository_owner  = split("/", replace(var.github_repo_url, "/(.*github.com/)/", ""))[0]
  with_vars_config  = yamldecode(templatefile("${path.root}/cloudbuild/with-variables.cloudbuild.yaml", { "variable_here" = "WORLD" }))
  simple_config   = yamldecode(templatefile("${path.root}/cloudbuild/simple.cloudbuild.yaml", {}))
}

resource "google_cloudbuild_trigger" "inline_github_with_vars" {
  project     = var.project_id
  # Make sure the location of the trigger matches the region your repository is added to.  
  location    = "global"
  name        = "trigger-with-inline-yaml-and-vars"
  description = "This trigger is deployed by terraform, with an in-line build config."
  github {
    name  = local.repository_name
    owner = local.repository_owner
    pull_request {
      branch          = "main"
      comment_control = "COMMENTS_ENABLED_FOR_EXTERNAL_CONTRIBUTORS_ONLY"
      invert_regex    = false
    }
  }
  build {
    images        = []
    substitutions = {}
    tags          = []
    dynamic "step" {
      for_each = local.with_vars_config.steps
      content {
        args = step.value.args
        name = step.value.name
      }
    }
  }
}