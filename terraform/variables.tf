variable "resource_group_location" {
  type        = string
  default     = "switzerlandnorth"
  description = "Location of the resource group."
}

variable "resource_group_name" {
  type = string
  default = "tfresourcegroup"
  description = "Name of the terraform resource group"
}

variable "environment_short" {
    type = string
    validation {
        condition = (contains(["prod", "int", "dev"], var.environment_short) || startswith(var.environment_short, "dev"))
        error_message = "Environment must be prod, int or dev*"
    }
}
