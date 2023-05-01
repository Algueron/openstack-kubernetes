# All OpenStack resources will use the Terraform variablecluster_name (defaultexample) in their name to make it easier to track. For example the first compute resource will be namedexample-kubernetes-1.
cluster_name = "production"

# List of Availability Zones available in your OpenStack cluster.
az_list = ["nova"]

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

# SSH key to use for access to nodes
public_key_path = "~/.ssh/id_rsa.pub"

# image to use for bastion, masters, standalone etcd instances, and nodes
image = "<image name>"

# user on the node (ex. core on Container Linux, ubuntu on Ubuntu, etc.)
ssh_user = "<cloud-provisioned user>"

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

flavor_k8s_master = "<UUID>"

k8s_masters = {
  # "master-1" = {
  #   "az"          = "nova"
  #   "flavor"      = "<UUID>"
  #   "floating_ip" = true
  #   "etcd" = true
  # },
  # "master-2" = {
  #   "az"          = "nova"
  #   "flavor"      = "<UUID>"
  #   "floating_ip" = false
  #   "etcd" = true
  # },
  # "master-3" = {
  #   "az"          = "nova"
  #   "flavor"      = "<UUID>"
  #   "floating_ip" = true
  #   "etcd" = true
  # },
}


# nodes
number_of_k8s_nodes = 2

number_of_k8s_nodes_no_floating_ip = 4

#flavor_k8s_node = "<UUID>"

# GlusterFS
# either 0 or more than one
#number_of_gfs_nodes_no_floating_ip = 0
#gfs_volume_size_in_gb = 150
# Container Linux does not support GlusterFS
#image_gfs = "<image name>"
# May be different from other nodes
#ssh_user_gfs = "ubuntu"
#flavor_gfs_node = "<UUID>"




subnet_cidr = "<cidr>"


bastion_allowed_remote_ips = ["0.0.0.0/0"]

# Force port security to be null. Some cloud providers do not allow to set port security.
# force_null_port_security = false
