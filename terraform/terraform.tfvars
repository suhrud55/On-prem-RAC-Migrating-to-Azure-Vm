resource_group_name   = "dev-rg"
location              = "East US"

vnet_name              = "dev-vnet"
vnet_cidr              = "10.0.0.0/16"
subnet1_cidr           = "10.0.1.0/24"
subnet2_cidr           = "10.0.2.0/24"

admin_username         = "oracleadmin"
ssh_public_key_path    = "~/.ssh/id_rsa.pub"

vm_size                = "Standard_E8ds_v5"
disk_size_gb           = 512
