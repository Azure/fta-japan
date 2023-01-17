variable "rg_shared" {
  type = object({
    name     = string
    location = string
  })
  default = {
    name     = "rg-monitoring-shared"
    location = "japaneast"
  }
}

variable "rg_web" {
  type = object({
    name     = string
    location = string
  })
  default = {
    name     = "rg-monitoring-web"
    location = "japaneast"
  }
}

variable "rg_prj" {
  type = object({
    name     = string
    location = string
  })
  default = {
    name     = "rg-monitoring-prj"
    location = "japaneast"
  }
}

variable "admin_username" {
  type      = string
  default   = "adminuser"
  sensitive = true
}

variable "admin_password" {
  type      = string
  default   = "Password1!"
  sensitive = true
}
