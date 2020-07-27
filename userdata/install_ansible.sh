#!/bin/bash
sudo yum update -y
sudo yum install epel-release -y
sudo yum install ansible -y
curl -O https://releases.ansible.com/ansible-tower/setup/ansible-tower-setup-latest.tar.gz
sudo tar -xvf ansible-tower-setup-latest.tar.gz
cd $(ls | grep ansible-tower-setup)
sudo sed -i "s,admin_password='',admin_password='Cyberark1',g" ./inventory
sudo sed -i "s,pg_password='',pg_password='Cyberark1',g" ./inventory
sudo sed -i "s,rabbitmq_password='',rabbitmq_password='Cyberark1',g" ./inventory
sudo sh setup.sh