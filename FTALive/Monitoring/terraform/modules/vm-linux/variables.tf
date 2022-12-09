variable "admin_username" {}
variable "admin_password" {}
variable "resource_group_name" {}
variable "location" {}
variable "name" {}
variable "zone" {
  default = null
}
variable "vm_size" {
  default = "Standard_B2ms"
}
variable "subnet_id" {}
variable "custom_data" {}
variable "source_address_prefix" {
  default = "*"
}
variable "private_ip_address_allocation" {
  default = "Dynamic"
}
variable "private_ip_address" {
  default = null
}
variable "source_image_reference" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })

  default = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
variable "enable_accelerated_networking" {
  type    = bool
  default = false
}

variable "availability_set_id" {
  default = null
}
