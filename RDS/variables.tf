variable "huaweicloud_access_key" {
  description = "your ak"
  type        = string
}

variable "huaweicloud_secret_key" {
  description = "your sk"
  type        = string
}

variable "vpc_name" {
  default = "vpc-A"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_name" {
  default = "subnet-1"
}

variable "subnet_cidr" {
  default = "10.0.0.0/24"
}

variable "subnet_gateway" {
  default = "10.0.0.1"
}


variable "allow_cidr" {
  default = "0.0.0.0/0"
}

variable "vpc_id" {
  default = "aa0c0d6b-dbb6-496e-a47d-643d9bfbbff7"
}

variable "subnet_id" {
  default = "ed290667-1aae-41e5-885d-599f4a55fdc4"
}

