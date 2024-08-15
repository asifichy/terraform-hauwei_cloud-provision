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

resource "huaweicloud_obs_bucket" "myexample" {
  bucket = "terraform-bucket1"
  acl    = "private"

  tags = {
    type = "bucket"
    env  = "Test"
  }
}
resource "huaweicloud_obs_bucket_object" "myobject1" {
  bucket = huaweicloud_obs_bucket.myexample.bucket
  key    = "myobject1"
  source = "hello.txt"
}

resource "huaweicloud_obs_bucket_object" "myobject2" {
  bucket       = huaweicloud_obs_bucket.myexample.bucket
  key          = "myobject2"
  content      = "content of myobject2"
  content_type = "application/xml"
}
