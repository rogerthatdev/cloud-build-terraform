# This Terraform won't create any Google Cloud resources, so additional 
# permissions are required for the service account
#
resource "random_string" "random" {
  length           = 16
  special          = true
  override_special = "/@£$"
}

output "random_string" {
    value = random_string.random.id
}