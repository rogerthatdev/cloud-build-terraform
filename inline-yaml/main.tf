# This Cloud Source Repo is used as a quick placeholder to use for the trigger 
# set up. 
resource "google_sourcerepo_repository" "placeholder" {
  project = var.project_id
  name    = "placeholder-repo"
}
########################
# The simplest example #
########################

/* 
This first trigger will have the following build config configured inline:
steps:
  - name: ubuntu
    args:
      - echo
      - hello world hey
timeout: 600s
*/
resource "google_cloudbuild_trigger" "simplest_inline" {
  project     = var.project_id
  location    = var.region
  name        = "01-simplest-inline-config-example"
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
    # This works because it's only one step
    step {
      name = "ubuntu"
      args = [
        "echo",
        "hello world hey"
      ]

    }
    timeout = "600s"
  }
}

####################
# A second example #
####################
/*
This next trigger will get its yaml config from an actual file, passed along
using Terraform's built-in yamldecode(). 

Let's get that yaml in here using a locals block:
*/
locals {
  simple_config_02 = yamldecode(templatefile("${path.root}/cloudbuild/02-simple.cloudbuild.yaml", {}))
}

resource "google_cloudbuild_trigger" "simple_inline_02" {
  project     = var.project_id
  location    = var.region
  name        = "02-simple-inline-config-example"
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
    # The single step is configured with name and args from the local value configured above
    step {
      name = local.simple_config_02.steps[0].name
      args = local.simple_config_02.steps[0].args
    }
  }
}

####################
# A third example  #
####################
/*


*/
locals {
  simple_config_03 = yamldecode(templatefile("${path.root}/cloudbuild/03-multi-step-dynamic.cloudbuild.yaml", {}))
}

resource "google_cloudbuild_trigger" "simple_inline_03" {
  project     = var.project_id
  location    = var.region
  name        = "03-simple-inline-config-example"
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
    # the cloud build config file defined in the locals block above
    dynamic "step" {
      for_each = local.simple_config_03.steps
      content {
        args = step.value.args
        name = step.value.name
      }
    }
  }
}