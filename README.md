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
sudo gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
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
````
- Install Kubespray requirements
````bash
sudo pip3 install -r requirements.txt
````
- Clone this repository
````bash
cd ~/
git clone https://github.com/Algueron/openstack-kubernetes.git
````
- Create the appropriate links between Terraform and Ansible
````bash
ln -s ~/kubespray/contrib/terraform/openstack/hosts ~/openstack-kubernetes/inventory/mycluster/
ln -s ~/kubespray/contrib ~/openstack-kubernetes/inventory/mycluster/
````
- Create the directory to store Ansible SSH options
````bash
mkdir ~/kubespray/contrib/terraform/openstack/group_vars
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
- Assign the role member and load-balancer_member to kubernetes
````bash
openstack role add --user kubernetes --project kubernetes member
openstack role add --user kubernetes --project kubernetes balancer_member
````
- Increase the quotas for the Kubernetes project
````bash
openstack quota set --cores 32 --instances 15 --ram 131072 --volumes 20 --secgroups 20 kubernetes
````

### Credentials Setup

- Move the clouds credentials to the appropriate directory
````bash
mkdir -p ~/.config/openstack
mv openstack-kubernetes/clouds.yaml ~/.config/openstack
````
- Edit the file to change the password property
````bash
vi ~/.config/openstack/clouds.yaml
````
- Edit the openrc file to change the password property
````bash
vi ~/openstack-kubernetes/kubernetes-openrc.sh
````

### Terraform configuration

- Edit the Terraform variables file
````bash
vi ~/openstack-kubernetes/inventory/mycluster/cluster.tfvars
````
- Retrieve the value for property external_net
````bash
external_net=$(openstack network show -f value -c id public-net)
````
- Retrieve the value for property flavor_k8s_master
````bash
flavor_k8s_master=$(openstack flavor show -f value -c id t2.medium)
````
- Retrieve the value for property flavor_k8s_node
````bash
flavor_k8s_node=$(openstack flavor show -f value -c id t2.xlarge)
````

### Infrastructure provisioning

- Dowload the required providers
````bash
cd ~/openstack-kubernetes/inventory/mycluster/
terraform -chdir="contrib/terraform/openstack" init
````
- Deploy the infrastructure
````bash
cd ~/openstack-kubernetes/inventory/mycluster/
export OS_CLOUD=openstack
terraform -chdir="contrib/terraform/openstack" apply -var-file=$PWD/cluster.tfvars
````
- Move the resulting Terrform state file into Ansible inventory
````bash
cp ~/kubespray/contrib/terraform/openstack/terraform.tfstate ~/openstack-kubernetes/inventory/mycluster/
````
- Move the Bastion host configuration into Ansible inventory
````bash
cp ~/kubespray/contrib/terraform/openstack/group_vars/no_floating.yml ~/openstack-kubernetes/inventory/mycluster/group_vars/
````

### Network tweaking

Being L3 CNI, calico and kube-router do not encapsulate all packages with the hosts' ip addresses. Instead the packets will be routed with the PODs ip addresses directly.

OpenStack will filter and drop all packets from ips it does not know to prevent spoofing.

In order to make L3 CNIs work on OpenStack you will need to tell OpenStack to allow pods packets by allowing the network they use.

- On a node with Openstack client installed, log in as kubernetes user and execute this command
````bash
openstack port list --device-owner=compute:nova -c ID -f value | xargs -tI@ openstack port set @ --allowed-address ip-address=10.233.0.0/18 --allowed-address ip-address=10.233.64.0/18
````
- Allow ICMP Protocol
````bash
openstack security group rule create --remote-ip "0.0.0.0/0" --protocol icmp --ingress mycluster-k8s
````
- Allow etcd ports
````bash
openstack security group rule create --remote-ip "0.0.0.0/0" --protocol tcp --dst-port 2379 --ingress mycluster-k8s-master
openstack security group rule create --remote-ip "0.0.0.0/0" --protocol tcp --dst-port 2380 --ingress mycluster-k8s-master
````

### Ansible configuration

- Edit the [Openstack configuration](inventory/mycluster/group_vars/all/openstack.yml) and set the variables

- external_openstack_lbaas_network_id
````bash
external_openstack_lbaas_network_id=$(openstack network show kubernetes-net -c id -f value)
````
- external_openstack_lbaas_subnet_id
````bash
external_openstack_lbaas_subnet_id=$(openstack subnet list --network kubernetes-net -c ID -f value)
````
- external_openstack_lbaas_floating_network_id
````bash
external_openstack_lbaas_floating_network_id=$(openstack network show public-net -c id -f value)
````
- external_openstack_lbaas_floating_subnet_id
````bash
external_openstack_lbaas_floating_subnet_id=$(openstack subnet list --network public-net -c ID -f value)
````

### Kubernetes Deployment

- Move to Kubespray root directory
````bash
cd ~/kubespray
````
- Check connectivity to all hosts
````bash
ansible -i ~/openstack-kubernetes/inventory/mycluster/hosts -m ping all
````
- Deploy Kubernetes
````bash
unset OS_CLOUD
source ~/openstack-kubernetes/kubernetes-openrc.sh
ansible-playbook --become -i ~/openstack-kubernetes/inventory/mycluster/hosts cluster.yml
````

### Rook volumes provisioning

- Create an additional volume for each worker node
````bash
source kubernetes-openrc.sh
for i in {1..5}
do
  openstack volume create --size 150 mycluster-k8s-node-nf-$i-volb
  openstack server add volume --device /dev/vdb mycluster-k8s-node-nf-$i mycluster-k8s-node-nf-$i-volb
done
````

### Kubernetes client configuration

- Download kubectl
````bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
````
- Retrieve Kubernetes first master's IP
````bash
MASTER_IP=$(~/openstack-kubernetes/inventory/mycluster/hosts --hostfile | grep mycluster-k8s-master-1 | awk '{print $1'})
````
- Get admin configuration file
````bash
ssh ubuntu@$MASTER_IP sudo cat /etc/kubernetes/admin.conf > admin.conf
````
- Set Master's IP
````bash
sed -i -e "s/127.0.0.1/$MASTER_IP/g" admin.conf
````
- Copy the configuration to the proper location
````bash
mkdir -p ~/.kube
cp admin.conf $HOME/.kube/config
````
- Check kubernetes configuration
````bash
./kubectl version
````
