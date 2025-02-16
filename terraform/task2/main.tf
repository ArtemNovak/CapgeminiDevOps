resource "azurerm_resource_group" "artemnovakgroup" {
  name     = "ArtemNovak"
  location = "westeurope"

}

resource "azurerm_storage_account" "artemnovakstorage" {
  name                     = "artemnovaktfstorage"
  resource_group_name      = azurerm_resource_group.artemnovakgroup.name
  location                 = azurerm_resource_group.artemnovakgroup.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  blob_properties {
    versioning_enabled = true
  }
}

resource "azurerm_storage_container" "artemnovakcontainer" {
  name               = "artemnovaktfcontainer"
  storage_account_id = azurerm_storage_account.artemnovakstorage.id
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.artemnovakgroup.location
  resource_group_name = azurerm_resource_group.artemnovakgroup.name

}

resource "azurerm_subnet" "mysubnet" {
  name                 = "mysubnet"
  resource_group_name  = azurerm_resource_group.artemnovakgroup.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# resource "azurerm_network_security_group" "mysecgroup" {
#   name                = "default-NSG"
#   location            = azurerm_resource_group.artemnovakgroup.location
#   resource_group_name = azurerm_resource_group.artemnovakgroup.name


#   security_rule {
#     name                       = "SSH"
#     priority                   = 100
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "22"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }

#   security_rule {
#     name                       = "HTTP"
#     priority                   = 110
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "80"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }
# }

# resource "azurerm_public_ip" "myip" {
#   name                = "artemnovakpublicip"
#   location            = azurerm_resource_group.artemnovakgroup.location
#   resource_group_name = azurerm_resource_group.artemnovakgroup.name
#   allocation_method   = "Static"
# }

# resource "azurerm_network_interface" "mynic" {
#   name                = "artenovaknic"
#   location            = azurerm_resource_group.artemnovakgroup.location
#   resource_group_name = azurerm_resource_group.artemnovakgroup.name

#   ip_configuration {
#     name                          = "internal"
#     subnet_id                     = azurerm_subnet.mysubnet.id
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id          = azurerm_public_ip.myip.id
#   }
# }

# resource "azurerm_subnet_network_security_group_association" "mynsgassoc" {
#   subnet_id                 = azurerm_subnet.mysubnet.id
#   network_security_group_id = azurerm_network_security_group.mysecgroup.id
# }

# resource "azurerm_linux_virtual_machine" "myvm" {
#   name                  = "artemnovakvm"
#   location              = azurerm_resource_group.artemnovakgroup.location
#   resource_group_name   = azurerm_resource_group.artemnovakgroup.name
#   size                  = "Standard_B2s"
#   admin_username        = "adminuser"
#   network_interface_ids = [azurerm_network_interface.mynic.id]

#   admin_ssh_key {
#     username   = "adminuser"
#     public_key = file("~/.ssh/id_rsa.pub")
#   }

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-jammy"
#     sku       = "22_04-lts"
#     version   = "latest"
#   }

#   custom_data = base64encode(<<-EOF
#       #!/bin/bash
#       apt-get update
#       apt-get install -y nginx
#       systemctl enable nginx
#       systemctl start nginx
#       EOF
#   )
# }

# output "vm_public_ip" {
#   value       = azurerm_public_ip.myip.ip_address
#   description = "The public IP address of the virtual machine"
# }