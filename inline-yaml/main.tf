locals {
  with_vars_config = yamldecode(templatefile("${path.root}/cloudbuild/with-variables.cloudbuild.yaml", { "variable_here" = "WORLD" }))
  simple_config    = yamldecode(templatefile("${path.root}/cloudbuild/simple.cloudbuild.yaml", {}))
}

resource "google_sourcerepo_repository" "placeholder" {
  project = var.project_id
  name    = "placeholder-repo"
}

resource "google_cloudbuild_trigger" "inline_github_with_vars" {
  project     = var.project_id
  location    = var.region
  name        = "trigger-with-inline-yaml-and-vars"
  description = "This trigger is deployed by terraform, with an in-line build config."
  trigger_template {
    branch_name  = "^main$"
    invert_regex = false
    project_id   = var.project_id
    repo_name    = google_sourcerepo_repository.placeholder.name
  }
  build {
    images        = []
    substitutions = {}
    tags          = []
    # This is the dynamic block that will create a step block for each step in
    # the cloud build config file.
    dynamic "step" {
      for_each = local.with_vars_config.steps
      content {
        args = step.value.args
        name = step.value.name
      }
    }
  }
}