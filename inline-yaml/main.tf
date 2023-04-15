# This Cloud Source Repo is used as a quick placeholder to use for the trigger 
# set up. 
resource "google_sourcerepo_repository" "placeholder" {
  project = var.project_id
  name    = "placeholder-repo"
}
#############################
# 01 - The simplest example #
#############################

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
    # This is a single step defined inline
    step {
      name = "ubuntu"
      args = [
        "echo",
        "hello world hey"
      ]
    }
    # You could define a second step here:
    # step {
    #   name = "ubuntu"
    #   args = [
    #     "echo",
    #     "hello world hey. again."
    #   ]
    # }
    timeout = "600s"
  }
}

#####################################
# 02 - An example using a yaml file #
#####################################

/*
This next trigger will get its yaml config from an actual file, passed along
using Terraform's built-in yamldecode(). 
*/
locals {
  # we bring in the yaml content via yamldecode() and templatefile()
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
    # The single step gets values for name and args from the yaml brought in via
    # the local value above. This works because there's only one step.
    step {
      name = local.simple_config_02.steps[0].name
      args = local.simple_config_02.steps[0].args
    }
  }
}

########################################################################
# 03 - An example using a yaml file with multiple steps (dynamic block)#
########################################################################

/*
This example uses a yaml file that includes 2 steps.
*/
locals {
  # once again: we bring in the yaml content via yamldecode() and templatefile()
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
    # the cloud build config file defined in the locals block above. This will
    # with as many steps as the build config file may have.
    dynamic "step" {
      for_each = local.simple_config_03.steps
      content {
        args = step.value.args
        name = step.value.name
      }
    }
  }
}

#######################################################
# 04 - Using values from terraform  in the build yaml #
#######################################################

/*
This example uses the dynamic block like the example above. This time the yaml 
file has some variables. 

The variables in the yaml file are enclosed in brackets like this: {variable}.
See cloudbuild/04-multi-step-dynamic-with-vars.cloudbuild.yaml
*/
locals {
  # You can pass values for variables in the yaml config via the second 
  # parameter of the templatefile() function:
  simple_config_04 = yamldecode(templatefile("${path.root}/cloudbuild/04-multi-step-dynamic-with-vars.cloudbuild.yaml", { "variable_here" = "WORLD", "another_variable" = "MARS" }))
}

resource "google_cloudbuild_trigger" "simple_inline_04" {
  project     = var.project_id
  location    = var.region
  name        = "04-simple-inline-config-example-with-vars"
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
    # This is the same dynamic block used in trigger 03 above
    dynamic "step" {
      for_each = local.simple_config_04.steps
      content {
        args = step.value.args
        name = step.value.name
      }
    }
  }
}