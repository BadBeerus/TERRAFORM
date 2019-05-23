provider "azurerm" {

}
data "azurerm_resource_group" "RgUSA" {
  name = "RessourceUSA"
}


data "azurerm_virtual_network" "dn1" {
  name                = "Network1"
  resource_group_name = "${data.azurerm_resource_group.RgUSA.name}"
}

data "azurerm_subnet" "dsn1" {
  name                 = "SubnetNetwork1"
  virtual_network_name = "${data.azurerm_virtual_network.dn1.name}"
  resource_group_name = "${data.azurerm_resource_group.RgUSA.name}"
}




resource "azurerm_public_ip" "myterraformpublicip" {
    count                        = 3
    name                         = "myPublicIP${count.index}"
    location                     = "eastus"
    resource_group_name          = "${data.azurerm_resource_group.RgUSA.name}"
    allocation_method            = "Dynamic"

    tags {
        environment = "Terraform Demo"
    }
}

resource "azurerm_network_interface" "myterraformnic" {
    
    count               = 3
    name                = "myNIC${count.index}"
    location            = "eastus"
    resource_group_name = "${data.azurerm_resource_group.RgUSA.name}"
    
    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${element(data.azurerm_subnet.dsn1.*.id, count.index)}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${element(azurerm_public_ip.myterraformpublicip.*.id, count.index)}"
    }

    tags {
        environment = "Terraform Demo"
    }
}

resource "azurerm_network_security_group" "myterraformnsg" {
    
    count               = 3
    name                = "myNetworkSecurityGroup${count.index}"
    location            = "eastus"
    resource_group_name = "${data.azurerm_resource_group.RgUSA.name}"
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags {
        environment = "Terraform Demo"
    }
}


resource "azurerm_virtual_machine" "myterraformvm" {
    count                 = 3
    name                  = "Machine2${count.index}"
    location              = "eastus"
    resource_group_name   = "${data.azurerm_resource_group.RgUSA.name}"
    network_interface_ids = ["${element(azurerm_network_interface.myterraformnic.*.id, count.index)}"]
    vm_size               = "Standard_B1ls"


    storage_os_disk {
        name              = "Machine2Disk${count.index}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "myvm${count.index}"
        admin_username = "azureuser"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/azureuser/.ssh/authorized_keys"
            key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQClkqP7axMaKDoIxNFCFDRTZAyk3dcZdWDaZbhIfdn3++umWwfMESoRF4T9RUho4UIzj1jjWz8HQGggAG5xixyA7unghpWkC1QRDr9DLiQ95NUI7NWop+PQ1GqgacNhWDDq5DPjjJkYzRd3fISA0vrMX+nwZwv80Z0JD2wPPAf8jyTI6Xax0kxHfMol4W8L5+W/uX1NoT/HsmFDayTEH202PvEwKXKZgybnurbZA7uYpAJJWhpF2xtxBieZFLgcqUlel/DEyt1l3m0GbQLoObDpZWqVQx4gzy8Zvf3YhEzcymR7rLPaOmJjblLe+4E2bPUWv6Vco4d+Xa0h4vf284fr user01@localhost.localdomain"
        }
    }

    tags {
        environment = "Terraform Demo"
    }
}