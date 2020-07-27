#!/bin/bash
sudo yum update -y
sudo yum install python37 python3-pip -y
pip3 install docker
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo chkconfig docker on
sudo usermod -a -G docker ec2-user