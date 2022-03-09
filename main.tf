provider "azurerm" {
  features {}
}

#create Resource Group
resource "azurerm_resource_group" "terraform-project" {
  name     = "terraform-project"
  location = "eastus"
}

#Create Virtual Network 
resource "azurerm_virtual_network" "terraform-vnet" {
  name                = "terraform-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.terraform-project.location
  resource_group_name = azurerm_resource_group.terraform-project.name
}

#Create Subnet to hold the VM 

resource "azurerm_subnet" "terraform-subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.terraform-project.name
  virtual_network_name = azurerm_virtual_network.terraform-subnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

#create vNIC for the VM
resource "azurerm_network_interface" "terraform-nic" {
  name                = "terraform-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.terraform-project.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.terraform-nic
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "terraform-machine" {
  name                = "terraform-machine"
  resource_group_name = azurerm_resource_group.terraform-project.name
  location            = azurerm_resource_group.terraform-project.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.terraform-nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}
