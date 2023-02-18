# Terraform with Cloud Build

This example will execute Terraform from a Cloud Build job.  

## Before you begin 

To run this, you'll need:
 - a Google Cloud Project with billing enabled
 - the [Cloud Build API](https://console.cloud.google.com/apis/library/cloudbuild.googleapis.com?project=tf-build-fafo-6bd3) enabled
 - the **Cloud Build Editor** and **Service Usage Consumer** roles assigned to your user account on the project (see [docs](https://cloud.google.com/build/docs/securing-builds/configure-access-to-resources#granting_permissions_to_run_gcloud_commands) for more on Cloud Build permissions)
 - the [`gloud`](https://cloud.google.com/sdk/gcloud) CLI installed (or you can use [Cloud Shell](https://shell.cloud.google.com/) in your project)
>> :warning: Docs say all the user needs is the Cloud Build Editor and Service 
>> Usage Consumer roles, but you may receive an error about missing permissions 
>> for GCS. If that's the case, use the Editor role on the project.
## Run it

1. Set your Google Cloud project:

    `gcloud config set project $PROJECT_ID`

1. Run Cloud Build using the provided configuration:
    
    `gcloud builds submit`

See your Cloud Build job by visiting the [Cloud Build Dashboard](https://console.cloud.google.com/cloud-build/builds) in your project.