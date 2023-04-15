variable "project_id" {
  type        = string
  description = "The Cloud project to deploy resources to."
}

variable "region" {
  type        = string
  description = "A default region for resources."
  default     = "us-central1"
}