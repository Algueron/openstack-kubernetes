###################################################
#                                                 #
#                      General                    #
#                                                 #
###################################################

# All OpenStack resources will use the Terraform variablecluster_name (defaultexample) in their name to make it easier to track. For example the first compute resource will be namedexample-kubernetes-1.
cluster_name = "production"

# List of Availability Zones available in your OpenStack cluster.
az_list = ["nova"]

###################################################
#                                                 #
#                     Networking                  #
#                                                 #
###################################################

# The name to be given to the internal network that will be generated
network_name = "kubernetes-net"

# Use a existing network with the name of network_name. Set to false to create a network with name of network_name.
use_existing_network = false

# An array of DNS name server names to be used by hosts in the internal subnet.
dns_nameservers = ["192.168.1.15", "1.1.1.1"]

# Name of the pool from which floating IPs will be allocated
floatingip_pool = "public-net"

# UUID of the external network that will be routed to
external_net = "<UUID>"

###################################################
#                                                 #
#                      Flavors                    #
#                                                 #
###################################################

# UUID of the flavor to use for master + etcd nodes
flavor_k8s_master = "<UUID>"

# UUID of the flavor to use for worker nodes
flavor_k8s_node = "<UUID>"

###################################################
#                                                 #
#                       Images                    #
#                                                 #
###################################################

# Name of the image to use in provisioning the compute resources. Should already be loaded into glance.
image = "ubuntu-server-22.04"

# The username to ssh into the image with. This usually depends on the image you have selected
ssh_user = "ubuntu"

# Path on your local workstation to the public key file you wish to use in creating the key pairs
public_key_path = "~/.ssh/id_rsa.pub"

###################################################
#                                                 #
#                     Instances                   #
#                                                 #
###################################################

# 
number_of_k8s_masters

# 0|1 bastion nodes
number_of_bastions = 0

#flavor_bastion = "<UUID>"

# standalone etcds
number_of_etcd = 0

# masters
number_of_k8s_masters = 1

number_of_k8s_masters_no_etcd = 0

number_of_k8s_masters_no_floating_ip = 0

number_of_k8s_masters_no_floating_ip_no_etcd = 0

# nodes
number_of_k8s_nodes = 2

number_of_k8s_nodes_no_floating_ip = 4

subnet_cidr = "<cidr>"


bastion_allowed_remote_ips = ["0.0.0.0/0"]

# Force port security to be null. Some cloud providers do not allow to set port security.
# force_null_port_security = false
