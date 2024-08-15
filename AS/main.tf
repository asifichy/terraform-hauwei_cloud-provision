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

data "huaweicloud_availability_zones" "myaz" {}

data "huaweicloud_compute_flavors" "myflavor" {
  availability_zone = data.huaweicloud_availability_zones.myaz.names[0]
  performance_type  = "normal"
  cpu_core_count    = 2
  memory_size       = 4
}

data "huaweicloud_images_image" "myimage" {
  name        = "Ubuntu 18.04 server 64bit"
  most_recent = true
}

resource "huaweicloud_compute_keypair" "mykeypair" {
  name = "my_keypair"
}

resource "huaweicloud_as_configuration" "my_as_config" {
  scaling_configuration_name = "my_as_config"

  instance_config {
    flavor   = "c7n.large.4"
    image    = "7251590b-5aad-44aa-a2a6-6f9c378137a7"
    key_name = huaweicloud_compute_keypair.mykeypair.name
    disk {
      size        = 40
      volume_type = "SSD"
      disk_type   = "SYS"
    }
    
  }
}

data "huaweicloud_vpc" "vpc" {
  name = "asif-vpc-test"
}

data "huaweicloud_vpc_subnet" "mynet" {
  name   = "subnet-2"
  vpc_id = "247f08c1-1069-4bfa-b9cb-69d478e7d76c"
}

data "huaweicloud_networking_secgroup" "secgroup_1" {
  name = "default"
}

resource "huaweicloud_as_group" "my_as_group" {
  scaling_group_name       = "my_as_group"
  scaling_configuration_id = huaweicloud_as_configuration.my_as_config.id
  desire_instance_number   = 2
  min_instance_number      = 0
  max_instance_number      = 10
  vpc_id                   = data.huaweicloud_vpc.vpc.id
  delete_publicip          = true
  delete_instances         = "yes"
  
  networks {
    id = data.huaweicloud_vpc_subnet.mynet.id
  }
  
  security_groups {
    id = data.huaweicloud_networking_secgroup.secgroup_1.id
  }
  
  tags = {
    owner = "AutoScaling"
  }
}

resource "huaweicloud_ces_alarmrule" "scaling_up_rule" {
  alarm_name = "scaling_up_rule"
  
  metric {
    namespace   = "SYS.AS"
    metric_name = "cpu_util"
    
    dimensions {
      name  = "AutoScalingGroup"
      value = huaweicloud_as_group.my_as_group.id
    }
  }
  
  condition {
    period              = 300
    filter              = "average"
    comparison_operator = ">="
    value               = 80
    unit                = "%"
    count               = 1
  }
  
  alarm_actions {
    type              = "autoscaling"
    notification_list = []
  }
}

resource "huaweicloud_as_policy" "scaling_up_policy" {
  scaling_policy_name = "scaling_up_policy"
  scaling_policy_type = "ALARM"
  scaling_group_id    = huaweicloud_as_group.my_as_group.id  
  alarm_id            = huaweicloud_ces_alarmrule.scaling_up_rule.id
  cool_down_time      = 300
  
  scaling_policy_action {
    operation       = "ADD"
    instance_number = 1
  }
}

resource "huaweicloud_ces_alarmrule" "scaling_down_rule" {
  alarm_name = "scaling_down_rule"
  
  metric {
    namespace   = "SYS.AS"
    metric_name = "cpu_util"
    
    dimensions {
      name  = "AutoScalingGroup"
      value = huaweicloud_as_group.my_as_group.id
    }
  }
  
  condition {
    period              = 300
    filter              = "average"
    comparison_operator = "<="
    value               = 20
    unit                = "%"
    count               = 1
  }
  
  alarm_actions {
    type              = "autoscaling"
    notification_list = []
  }
}

resource "huaweicloud_as_policy" "scaling_down_policy" {
  scaling_policy_name = "scaling_down_policy"
  scaling_policy_type = "ALARM"
  scaling_group_id    = huaweicloud_as_group.my_as_group.id  
  alarm_id            = huaweicloud_ces_alarmrule.scaling_down_rule.id
  cool_down_time      = 300
  
  scaling_policy_action {
    operation       = "REMOVE"
    instance_number = 1
  }
}
