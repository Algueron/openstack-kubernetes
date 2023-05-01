# Kubernetes on Openstack
Terraform and Ansible project to setup a Kubernetes cluster on Openstack. 
I'll use custom scripts instead of managed Kubernetes to try to keep the Kubernetes cluster as "Cloud Agnostic" as possible.

## Terraform Setup

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
- Assign the role member to terraform
````bash
openstack role add --user terraform --project terraform member
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
- Set the correct permissions on the private key
````bash
chmod 400 terraform.key
````

### Virtual Machine

- Create an Ubuntu virtual machine
````bash
openstack server create --flavor t2.small --image ubuntu-server-22.04 --network terraform-net --security-group default --security-group allow-ssh --key-name terraform-key terraform
````
- Create a Floating IP
````bash
openstack floating ip create public-net
````
- Store the IP generated
````bash
TF_FLOATING_IP=$(openstack floating ip list -f value -c "Floating IP Address")
````
- Assign the floating IP to the Virtual Machine
````bash
openstack server add floating ip terraform $TF_FLOATING_IP
````

### Terraform Setup

- Log into the Terraform VM using the floating ip and private key
````bash
ssh -i terraform.key ubuntu@$TF_FLOATING_IP
````
- Install gpg.
````bash
sudo apt install gpg
````
- Download the signing key to a new keyring.
````bash
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
````
- Verify the key's fingerprint.
````bash
gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
````
- Add the official HashiCorp Linux repository.
````bash
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
````
- Update and install Terraform.
````bash
sudo apt-get update && sudo apt-get install terraform
````

## Kubespray Setup

- Install PIP
````bash
sudo apt install -y python3-pip
````
- Clone Kubespray repository
````bash
cd ~/
git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray
git checkout release-2.21
````
- Install Kubespray requirements
````bash
sudo pip3 install -r requirements.txt
````

## Kubernetes Infrastructure setup

### Project creation

- Log as Openstack admin user
````bash
source admin-openrc.sh
````
- Create the Kubernetes project
````bash
openstack project create --description 'Kubernetes Home Cluster' kubernetes --domain default
````
- Create a Kubernetes user
````bash
openstack user create --project kubernetes --password PASSWORD kubernetes
````
- Assign the role member to kubernetes
````bash
openstack role add --user kubernetes --project kubernetes member
````
- Increase the quotas for the Kubernetes project
````bash
openstack quota set --cores 32 --instances 15 --ram 131072 --volumes 20 --secgroups 20 kubernetes
````

### Credentials Setup

- Clone this repository
````bash
git clone https://github.com/Algueron/openstack-kubernetes.git
````
- Move the clouds credentials to the appropiate directory
````bash
mkdir -p ~/.config/openstack
mv openstack-kubernetes/clouds.yaml ~/.config/openstack
````
- Edit the file to change the password property
````bash
vi ~/.config/openstack/clouds.yaml
````

### Terraform configuration

- Edit the Terraform variables file
````bash
vi ~/openstack-kubernetes/inventory/mycluster/cluster.tfvars
````
- Retrieve the value for property external_net
````bash
EXT_NET_UUID=$(openstack network show -f value -c id public-net)
````
