locals {
  repository_name   = split("/", replace(var.github_repo_url, "/(.*github.com/)/", ""))[1]
  repository_owner  = split("/", replace(var.github_repo_url, "/(.*github.com/)/", ""))[0]
  test_build_config = yamldecode(templatefile("${path.module}/cloudbuild/test.cloudbuild.yaml", { "test" = "a test variable via tf temlatefile()" }))
  pr_build_config   = yamldecode(templatefile("${path.module}/cloudbuild/pr.cloudbuild.yaml", {}))
}

resource "google_cloudbuild_trigger" "inline_github" {
  project     = var.project_id
  location    = var.region
  name        = "trigger-with-inline-yaml"
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
      for_each = local.pr_build_config.steps
      content {
        args = step.value.args
        name = step.value.name
      }
    }
  }
  substitutions = {}
}