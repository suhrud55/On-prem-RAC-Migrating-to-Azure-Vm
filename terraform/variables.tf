variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "vnet_name" {
  type        = string
}

variable "vnet_cidr" {
  type        = string
}

variable "subnet1_cidr" {
  type        = string
}

variable "subnet2_cidr" {
  type        = string
}

variable "admin_username" {
  type        = string
}

variable "ssh_public_key_path" {
  type        = string
}

variable "vm_size" {
  type        = string
}

variable "disk_size_gb" {
  type        = number
}
