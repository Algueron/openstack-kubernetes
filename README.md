# Kubernetes on Openstack
Terraform and Ansible project to setup a Kubernetes cluster on Openstack. 
I'll use custom scripts instead of managed Kubernetes to try to keep the Kubernetes cluster as "Cloud Agnostic" as possible.

## Terraform Infrastructure setup

### Project creation

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
- Download the terraform [credentials file](terraform-openrc.sh)
````bash
wget https://raw.githubusercontent.com/Algueron/openstack-kubernetes/main/terraform-openrc.sh
````
- Edit the variable OS_PASSWORD to use your real password

### Networking setup

- Log as Openstack terraform user
````bash
source terraform-openrc.sh
````
- Create a private network for terraform
````bash
openstack network create --enable terraform-net
````
- Create a private subnet
````bash
openstack subnet create --subnet-range "192.168.75.0/24" --dhcp --ip-version 4 --dns-nameserver "192.168.1.15" --network terraform-net terraform-subnet
````
- Create a router connected to the Provider network
````bash
openstack router create --enable --external-gateway public-net terraform-router
````
- Connect the router to the terraform network
````bash
openstack router add subnet terraform-router terraform-subnet
````

### Security groups

- Create a security group to allow SSH
````bash
openstack security group create --stateful allow-ssh
````
- Add the rule to allow SSH
````bash
openstack security group rule create --remote-ip "192.168.0.0/24" --protocol tcp --dst-port 22 --ingress allow-ssh
````

### SSH Keys

- Create a keypair
````bash
openstack keypair create --private-key terraform.key --type ssh terraform-key
````

### Create the Virtual Machine

- Create an Ubuntu virtual machine
````bash
openstack server create --flavor t2.small --image ubuntu-server-22.04 --network terraform-net --security-group default --security-group allow-ssh --key-name terraform-key terraform
````
