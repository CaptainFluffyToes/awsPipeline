provider "aws" {
    region = "us-east-1"
}

resource "aws_launch_template" "docker_nodes" {
  name = "docker_nodes"
  description = "This will install docker on amazon linux 2 machines. It will also install python3 and pip3."
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 30
      delete_on_termination = true
      volume_type = "standard"
    }
  }
  image_id = "ami-09d95fab7fff3776c"
  instance_type = "t2.medium"
  key_name = "dk-master"
  metadata_options {
    http_endpoint = "enabled"
    http_tokens = "optional"
  }
  network_interfaces {
    delete_on_termination = true
    security_groups = ["sg-0364d25c8b5cd0390"]
    subnet_id = "subnet-02bc26737e42d7620"
  }

  user_data = filebase64("${path.module}/files/terraform/user_data.sh")

}