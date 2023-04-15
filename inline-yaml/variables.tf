variable "project_id" {
  type        = string
  description = "The Cloud project to deploy resources to."
}

variable "region" {
  type        = string
  description = "A default region for resources."
  default     = "us-central1"
}
variable "github_repo_url" {
  type        = string
  description = "The URL of a github repository connected to your Google Cloud Project via https://console.cloud.google.com/cloud-build/triggers/connect (example: github.com/yourgithubusername/yourrepo)"
}
