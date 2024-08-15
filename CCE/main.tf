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

data "huaweicloud_images_image" "myimage" {
  name        = "Ubuntu 18.04 server 64bit"
  most_recent = true
}

data "huaweicloud_vpc" "vpc" {
  name = "asif-vpc-test"
  cidr = "192.172.72.0/24"
}

data "huaweicloud_vpc_subnet" "mynet" {
  name = "subnet-2"
  vpc_id = "247f08c1-1069-4bfa-b9cb-69d478e7d76c"
  cidr = "192.172.72.16/28"
}

resource "huaweicloud_compute_keypair" "mykeypair" {
  name  = "mykeypair"
}

resource "huaweicloud_cce_cluster" "cluster" {
  name                   = "terraform-cce"
  cluster_type           = "VirtualMachine"
  cluster_version        = "v1.28"
  flavor_id              = "cce.s2.medium"
  vpc_id                 = data.huaweicloud_vpc.vpc.id
  subnet_id              = data.huaweicloud_vpc_subnet.mynet.id
  container_network_type = "overlay_l2"
  authentication_mode    = "rbac"
  delete_all             = "true"
}

resource "huaweicloud_cce_node" "mynode" {
  cluster_id        = huaweicloud_cce_cluster.cluster.id
  name              = "terraform-node-1"
  flavor_id         = "t6.large.2"
  availability_zone = data.huaweicloud_availability_zones.myaz.names[0]
  key_pair          = huaweicloud_compute_keypair.mykeypair.name

  root_volume {
    size       = 40
    volumetype = "SAS"
  }
  data_volumes {
    size       = 100
    volumetype = "SAS"
  }
}

resource "huaweicloud_cce_node" "mynode2" {
  cluster_id        = huaweicloud_cce_cluster.cluster.id
  name              = "terraform-node-2"
  flavor_id         = "s6.large.2"
  availability_zone = data.huaweicloud_availability_zones.myaz.names[0]
  key_pair          = huaweicloud_compute_keypair.mykeypair.name

  root_volume {
    size       = 80
    volumetype = "SAS"
  }
  data_volumes {
    size       = 100
    volumetype = "SAS"
  }
}
