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

# Number of nodes that serve as both master and etcd. These can be provisioned with or without floating IP addresses
number_of_k8s_masters = 3
number_of_k8s_masters_no_floating_ip = 0

# Number of nodes that serve as just master with no etcd. These can be provisioned with or without floating IP addresses
number_of_k8s_masters_no_etcd = 0
number_of_k8s_masters_no_floating_ip_no_etcd = 0

# Number of pure etcd nodes
number_of_etcd = 0

# Kubernetes worker nodes. These can be provisioned with or without floating ip addresses.
number_of_k8s_nodes = 0
number_of_k8s_nodes_no_floating_ip = 5

# Number of bastion hosts to create. Scripts assume this is really just zero or one
number_of_bastions = 0

# Number of gluster servers to provision.
number_of_gfs_nodes_no_floating_ip = 0

###################################################
#                                                 #
#                      Security                   #
#                                                 #
###################################################

# If 1, nodes with floating IPs will transmit internal cluster traffic via floating IPs; if 0 private IPs will be used instead. Default value is 1.
use_access_ip = 1

# Allow to disable port security by setting this to false. true by default
port_security_enabled = true

# List of CIDR blocks allowed to initiate an API connection, ["0.0.0.0/0"] by default
master_allowed_remote_ips = ["192.168.0.0/24"]

# List of CIDR allowed to initiate a SSH connection, empty by default
k8s_allowed_remote_ips = ["192.168.0.0/24"]

# List of CIDR allowed to initiate a SSH connection, ["0.0.0.0/0"] by default
bastion_allowed_remote_ips = ["192.168.0.0/24"]

# Set null instead of true or false for port_security. false by default
force_null_port_security = false

###################################################
#                                                 #
#                      Storage                    #
#                                                 #
###################################################

# Volume type of the root volume for control_plane, 'Default' by default
# master_volume_type = 

# Volume type of the root volume for nodes, 'Default' by default
# node_volume_type = 

# Size of the root volume for masters, 0 to use ephemeral storage
master_root_volume_size_in_gb = 0

# Size of the root volume for nodes, 0 to use ephemeral storage
node_root_volume_size_in_gb = 0

# Size of the root volume for etcd nodes, 0 to use ephemeral storage
etcd_root_volume_size_in_gb = 0

# Size of the root volume for bastions, 0 to use ephemeral storage
bastion_root_volume_size_in_gb = 0
