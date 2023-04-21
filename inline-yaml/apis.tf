module "project_services" {
  source                      = "terraform-google-modules/project-factory/google//modules/project_services"
  version                     = "13.0.0"
  disable_services_on_destroy = false
  project_id                  = var.project_id
  enable_apis                 = true

  activate_apis = [
    "cloudbuild.googleapis.com",
    "sourcerepo.googleapis.com"

  ]
}

resource "time_sleep" "project_services" {
  depends_on = [
    module.project_services
  ]
  create_duration = "45s"
}