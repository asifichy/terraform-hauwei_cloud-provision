terraform {
  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = ">= 1.62.1"
    }
  }
}

provider "huaweicloud" {
  region      = "ap-southeast-3"
  access_key  = var.huaweicloud_access_key
  secret_key  = var.huaweicloud_secret_key
}

data "huaweicloud_availability_zones" "myaz" {

}

resource "huaweicloud_vpc_eip" "myeip" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "mybandwidth"
    size        = 50
    share_type  = "PER"
    charge_mode = "traffic"
  }
}

resource "huaweicloud_compute_eip_associate" "associated" {
  public_ip   = huaweicloud_vpc_eip.myeip.address
  instance_id = huaweicloud_compute_instance.ECS-Terraform.id
}

data "huaweicloud_images_image" "myimage" {
  name        = "Ubuntu 18.04 server 64bit"
  most_recent = true
}

data "huaweicloud_vpc" "vpc" {
  name = "asif-vpc-test"
  cidr = "192.172.72.0/24"
}

data "huaweicloud_vpc_subnet" "mynet" {
  name             = "subnet-2"
  vpc_id           = "247f08c1-1069-4bfa-b9cb-69d478e7d76c"
}

resource "huaweicloud_compute_instance" "ECS-Terraform" {
  name              = "Terraform-ECS"
  availability_zone = data.huaweicloud_availability_zones.myaz.names[0]
  flavor_name       = "s3.xlarge.2"  # Replace with the desired flavor
  image_id = data.huaweicloud_images_image.myimage.id

  network {
    uuid = "c99cb168-9426-4517-b3ea-7116b6f233d6"
  }

  security_groups = ["default"]

  system_disk_type = "SAS"
  system_disk_size = 60  

  data_disks{
    type = "SAS"
    size = "10"
  }

}
