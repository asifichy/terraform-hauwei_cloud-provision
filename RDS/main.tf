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

data "huaweicloud_vpc" "vpc" {
  name = "vpc-A"
  cidr = "10.0.0.0/16"
}

data "huaweicloud_vpc_subnet" "mysubnet" {
  vpc_id      = "aa0c0d6b-dbb6-496e-a47d-643d9bfbbff7"
  name        = "subnet-1"
  cidr        = "10.0.0.0/24"
  gateway_ip  = "10.0.0.1"
}
resource "random_password" "mypassword" {
  length           = 12
  special          = true
  override_special = "!@#%^*-_=+"
}

resource "huaweicloud_rds_instance" "myinstance" {
  name                = "terraform-test"
  flavor              = "rds.mysql.x1.large.2.ha"
  ha_replication_mode = "async"
  vpc_id              = data.huaweicloud_vpc.vpc.id
  subnet_id           = data.huaweicloud_vpc_subnet.mysubnet.id

  security_group_id = "8d30cc75-3b91-4c07-9e42-7b8a2b813fb5"
  availability_zone = [
    data.huaweicloud_availability_zones.myaz.names[0],
    data.huaweicloud_availability_zones.myaz.names[1]
  ]


  db {
    type     = "MySQL"
    version  = "8.0"
    password = random_password.mypassword.result
  }
  volume {
    type = "CLOUDSSD"
    size = 40
  }
}

resource "huaweicloud_vpc_eip" "myeip" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "test"
    size        = 300
    share_type  = "PER"
    charge_mode = "traffic"
  }
}

data "huaweicloud_networking_port" "rds_port" {
  network_id = data.huaweicloud_vpc_subnet.mysubnet.id
  fixed_ip   = huaweicloud_rds_instance.myinstance.private_ips[0]
}

resource "huaweicloud_vpc_eip_associate" "associated" {
  public_ip = huaweicloud_vpc_eip.myeip.address
  port_id   = data.huaweicloud_networking_port.rds_port.id
}
