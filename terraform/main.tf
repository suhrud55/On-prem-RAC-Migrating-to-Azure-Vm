################ Resource Group ################
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

################ VNET ################
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.vnet_cidr]
}

################ Subnets ################
resource "azurerm_subnet" "subnet1" {
  name                 = "private-subnet-1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet1_cidr]
}

resource "azurerm_subnet" "subnet2" {
  name                 = "private-subnet-2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet2_cidr]
}

################ NSG ################
resource "azurerm_network_security_group" "oracle_nsg" {
  name                = "oracle-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.vnet_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "OracleDB"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1521"
    source_address_prefix      = var.vnet_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "GoldenGate"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["7809", "7810-7820"]
    source_address_prefix      = var.vnet_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ActiveDataGuard"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1522"
    source_address_prefix      = var.vnet_cidr
    destination_address_prefix = "*"
  }
}

################ NSG Association ################
resource "azurerm_subnet_network_security_group_association" "subnet1_nsg" {
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.oracle_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "subnet2_nsg" {
  subnet_id                 = azurerm_subnet.subnet2.id
  network_security_group_id = azurerm_network_security_group.oracle_nsg.id
}

################ NICs ################
resource "azurerm_network_interface" "nic1" {
  name                = "oracle-nic-1"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "nic2" {
  name                = "oracle-nic-2"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet2.id
    private_ip_address_allocation = "Dynamic"
  }
}

################ VMs ################
resource "azurerm_linux_virtual_machine" "vm1" {
  name                = "oracle-vm-1"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.nic1.id
  ]

  ############################
  # Cloud-init / user data
  ############################
  custom_data = base64encode(
    file("primary.sh")
  )

  os_disk {
    storage_account_type = "Premium_LRS"
    caching              = "ReadWrite"
  }

  source_image_reference {
    publisher = "Oracle"
    offer     = "Oracle-Linux"
    sku       = "ol8-lvm"
    version   = "latest"
  }

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }
}

resource "azurerm_linux_virtual_machine" "vm2" {
  name                = "oracle-vm-2"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.nic2.id
  ]

  ############################
  # Cloud-init / user data
  # (Oracle DB only – Standby)
  ############################
  custom_data = base64encode(
    file("standby.sh")
  )

  os_disk {
    storage_account_type = "Premium_LRS"
    caching              = "ReadWrite"
  }

  source_image_reference {
    publisher = "Oracle"
    offer     = "Oracle-Linux"
    sku       = "ol8-lvm"
    version   = "latest"
  }

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }
}


################ Managed Disk ################(optional)
#resource "azurerm_managed_disk" "data_disk_vm1" {
  #name                 = "oracle-data-disk-vm1"
  #location             = var.location
  #resource_group_name  = azurerm_resource_group.rg.name
  #storage_account_type = "Premium_LRS"
  #create_option        = "Empty"
  #disk_size_gb         = var.disk_size_gb
}

#resource "azurerm_virtual_machine_data_disk_attachment" "attach_vm1" {
  #managed_disk_id    = azurerm_managed_disk.data_disk_vm1.id
  #virtual_machine_id = azurerm_linux_virtual_machine.vm1.id
  #lun                = 0
  #caching            = "ReadOnly"
}


###################
# Managed Disk – Standby VM
###################

#resource "azurerm_managed_disk" "data_disk_vm2" {
  #name                 = "oracle-data-disk-vm2"
  #location             = var.location
  #resource_group_name  = azurerm_resource_group.rg.name
  #storage_account_type = "Premium_LRS"
  #create_option        = "Empty"
  #disk_size_gb         = var.disk_size_gb
}

#resource "azurerm_virtual_machine_data_disk_attachment" "attach_vm2" {
  #managed_disk_id    = azurerm_managed_disk.data_disk_vm2.id
  #virtual_machine_id = azurerm_linux_virtual_machine.vm2.id
  #lun                = 0
  #caching            = "ReadOnly"
}

