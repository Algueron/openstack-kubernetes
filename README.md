# Kubernetes on Openstack
Terraform and Ansible project to setup a Kubernetes cluster on Openstack. 
I'll use custom scripts instead of managed Kubernetes to try to keep the Kubernetes cluster as "Cloud Agnostic" as possible.

## Terraform project creation

- Log as Openstack admin user
````bash
source admin-openrc.sh
````
- Create a Terraform project
````bash
openstack project create --description 'Terraform Hosts for provisioning' terraform --domain default
````
- Create a Terraform user
````bash
openstack user create --project terraform --password PASSWORD terraform
````
- Assign the role admin to terraform
````bash
openstack role add --user terraform --project terraform admin
````

## Terraform VM Setup

