# GCP FortiGate
Terraform workspace to deploy FortiGate Inbound Security on GCP.

## Requirements
In order to apply this code, you need to configure the following:

### Service Account
You should create a service account on your GCP projects. You should have at least two GCP projects: host-fortigate and service-fortigate.
On both projects, you should grant the following permissions to the service account:
 - Compute Instance Admin (v1)
 - Compute Network Admin
 - Service Account Admin
 - Compute Security Admin
 - Role Administrator
 - Service Account User

Other than that, download the public key of this service account and update the file `environment/root.hcl` with the credentials path of your public key.

### Enable Services
Once you create the projects host-fortigate and service-fortigate, you should enable the following services on your projects:
 - Compute Engine API
 - Network Connectivity API
 - Identity and Access Management (IAM) API

## Run the code
Access the environment folder and run terragrunt apply:

```
cd environment
terragrunt run-all apply
```
