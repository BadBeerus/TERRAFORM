provider "azurerm" {

}
resource "azurerm_resource_group" "rg" {
 name     = "RessourceEastUs"
 location = "eastus"

 tags {
     environment = "dev"
 }
}

resource "azurerm_virtual_network" "vn1" {
 name                = "vnusa1"
 address_space       = ["10.0.0.0/16"]
 location            = "${azurerm_resource_group.rg.location}"
 resource_group_name = "${azurerm_resource_group.rg.name}"

 tags {
     environment = "dev"
 }

}

resource "azurerm_virtual_network" "vn2" {
 name                = "vnusa2"
 address_space       = ["10.0.0.0/16"]
 location            = "${azurerm_resource_group.rg.location}"
 resource_group_name = "${azurerm_resource_group.rg.name}"

 tags {
     environment = "dev"
 }

}

resource "azurerm_virtual_network" "vn3" {
 name                = "vnusa3"
 address_space       = ["10.0.0.0/16"]
 location            = "${azurerm_resource_group.rg.location}"
 resource_group_name = "${azurerm_resource_group.rg.name}"

 tags {
     environment = "dev"
 }

}



resource "azurerm_subnet" "sub1" {
 name                 = "subusa1"
 resource_group_name  = "${azurerm_resource_group.rg.name}"
 virtual_network_name = "${azurerm_virtual_network.vn1.name}"
 address_prefix       = "10.0.2.0/24"

}

resource "azurerm_subnet" "sub2" {
 name                 = "subusa2"
 resource_group_name  = "${azurerm_resource_group.rg.name}"
 virtual_network_name = "${azurerm_virtual_network.vn2.name}"
 address_prefix       = "10.0.2.0/24"

}

resource "azurerm_subnet" "sub3" {
 name                 = "subusa3"
 resource_group_name  = "${azurerm_resource_group.rg.name}"
 virtual_network_name = "${azurerm_virtual_network.vn3.name}"
 address_prefix       = "10.0.2.0/24"

 
}

resource "azurerm_public_ip" "myterraformpublicip" {
    count                        = 4
    name                         = "IPmachine${count.index}"
    location                     = "${azurerm_resource_group.rg.location}"
    resource_group_name          = "${azurerm_resource_group.rg.name}"
    allocation_method            = "Dynamic"

    tags {
        environment = "dev"

    }
}
resource "azurerm_network_interface" "myterraformnic1" {
    
    count               = 2
    name                = "myNIC1${count.index}"
    location            = "${azurerm_resource_group.rg.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"

    ip_configuration {
        name                          = "myNicConfiguration1"
        subnet_id                     = "${azurerm_subnet.sub1.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${element(azurerm_public_ip.myterraformpublicip.*.id, count.index)}"
    }

}
resource "azurerm_network_interface" "myterraformnic2" {
    
    name                = "myNIC2"
    location            = "${azurerm_resource_group.rg.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"

    ip_configuration {
        name                          = "myNicConfiguration2"
        subnet_id                     = "${azurerm_subnet.sub2.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${element(azurerm_public_ip.myterraformpublicip.*.id, 2)}"
    }

}
resource "azurerm_network_interface" "myterraformnic3" {
    
    name                = "myNIC3"
    location            = "${azurerm_resource_group.rg.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"

    ip_configuration {
        name                          = "myNicConfiguration2"
        subnet_id                     = "${azurerm_subnet.sub3.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${element(azurerm_public_ip.myterraformpublicip.*.id, 3)}"
    }
}
resource "azurerm_network_security_group" "myterraformnsg1" {
    
    name                = "myNetworkSecurityGroup1"
    location            = "${azurerm_resource_group.rg.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    
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

    security_rule {
        name                       = "IN-HTTP"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "OUT-HTTP"
        priority                   = 1003
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "7050"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    
    }
    
    tags {
        environment = "dev"
    }

}
 
resource "azurerm_subnet_network_security_group_association" "asso1" {
    
    subnet_id = "${azurerm_subnet.sub1.id}"
    network_security_group_id = "${azurerm_network_security_group.myterraformnsg1.id}"      
}

resource "azurerm_network_security_group" "myterraformnsg2" {
    
    name                = "myNetworkSecurityGroup2"
    location            = "${azurerm_resource_group.rg.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"

    security_rule {
        name                       = "IN-HTTP"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "7050"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "OUT-HTTP"
        priority                   = 1002
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "1251"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    
    }
    
    tags {
        environment = "dev"
    }

}

resource "azurerm_subnet_network_security_group_association" "asso2" {
    
    subnet_id = "${azurerm_subnet.sub2.id}"
    network_security_group_id = "${azurerm_network_security_group.myterraformnsg2.id}"      
}

resource "azurerm_network_security_group" "myterraformnsg3" {
    
    name                = "myNetworkSecurityGroup3"
    location            = "${azurerm_resource_group.rg.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"

    security_rule {
        name                       = "IN-HTTP"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "1251"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "OUT-HTTP"
        priority                   = 1002
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "445"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    
    }
    
    tags {
        environment = "dev"
    }

}
 
resource "azurerm_subnet_network_security_group_association" "asso3" {
    
    subnet_id = "${azurerm_subnet.sub3.id}"
    network_security_group_id = "${azurerm_network_security_group.myterraformnsg3.id}"      
}

resource "azurerm_virtual_machine" "myterraformvm1" {
    
    count                 = 2
    name                  = "Machinetech${count.index}"
    location              = "${azurerm_resource_group.rg.location}"
    resource_group_name   = "${azurerm_resource_group.rg.name}"
    network_interface_ids = ["${element(azurerm_network_interface.myterraformnic1.*.id, count.index)}"]
    vm_size               = "Standard_B1ls"


    storage_os_disk {
        name              = "TechDisk${count.index}"
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
        computer_name  = "myvmTech${count.index}"
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
        environment = "dev"
        couche = "tech"

    
    }

}
resource "azurerm_virtual_machine" "myterraformvm2" {
    
    name                  = "MachineApp"
    location              = "${azurerm_resource_group.rg.location}"
    resource_group_name   = "${azurerm_resource_group.rg.name}"
    network_interface_ids = ["${element(azurerm_network_interface.myterraformnic2.*.id, count.index)}"]
    vm_size               = "Standard_B1ls"


    storage_os_disk {
        name              = "AppDisk"
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
        computer_name  = "myvmApp"
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
        environment = "dev"
        couche = "Apps"

    
    }

}
resource "azurerm_virtual_machine" "myterraformvm3" {
    
    name                  = "MachineData"
    location              = "${azurerm_resource_group.rg.location}"
    resource_group_name   = "${azurerm_resource_group.rg.name}"
    network_interface_ids = ["${element(azurerm_network_interface.myterraformnic3.*.id, count.index)}"]
    vm_size               = "Standard_B1ls"


    storage_os_disk {
        name              = "DataDisk"
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
        computer_name  = "myvmData"
        admin_username = "azureuser"
    } 
 
    os_profile_linux_config { 
        disable_password_authentication = true 
        ssh_keys { 
            path     = "/home/azureuser/.ssh/authorized_keys" 
            key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCl kqP7axMaKDoIxNFCFDRTZAyk3dcZdWDaZbhIfdn3++umWwfMESoRF4T9RUho4UIzj1jjWz8HQGggAG5xixyA7unghpWkC1QRDr9DLiQ95NUI7NWop+PQ1GqgacNhWDDq5DPjjJkYzRd3fISA0vrMX+nwZwv80Z0JD2wPPAf8jyTI6Xax0kxHfMol4W8L5+W/uX1NoT/HsmFDayTEH202PvEwKXKZgybnurbZA7uYpAJJWhpF2xtxBieZFLgcqUlel/DEyt1l3m0GbQLoObDpZWqVQx4gzy8Zvf3YhEzcymR7rLPaOmJjblLe+4E2bPUWv6Vco4d+Xa0h4vf284fr user01@localhost.localdomain"
        }
    }

    tags {
        environment = "dev"
        couche = "data"

    
    }

}

