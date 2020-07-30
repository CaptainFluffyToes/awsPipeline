#!/bin/bash
sudo yum update -y
sudo yum install epel-release -y
sudo yum install ansible jq -y
curl -O https://releases.ansible.com/ansible-tower/setup/ansible-tower-setup-latest.tar.gz
sudo tar -xvf ansible-tower-setup-latest.tar.gz
cd $(ls | grep ansible-tower-setup)
sudo sed -i "s,admin_password='',admin_password='Cyberark1',g" ./inventory
sudo sed -i "s,pg_password='',pg_password='Cyberark1',g" ./inventory
sudo sed -i "s,rabbitmq_password='',rabbitmq_password='Cyberark1',g" ./inventory
sudo sh setup.sh
curl --location --request POST 'https://localhost/api/v2/config/' \
--header 'Content-Type: application/json' \
--header 'Authorization: Basic e3t1c2VybmFtZX19Ont7cGFzc3dvcmR9fQ==' \
--data-raw '{
    "eula_accepted": "true",
    "company_name": "Cyberark",
    "contact_email": "sales@cyberark.com",
    "contact_name": "Demo User",
    "hostname": "4be94852de604058b8f0028de32b1c15",
    "instance_count": 10,
    "license_date": 2115311474,
    "license_key": "42d8e39360ba5a5d5134d1c5670119f2d8d27f2eb515fedbe1e1264d419f5359",
    "license_type": "basic",
    "subscription_name": "Red Hat Ansible Tower, Self-Support (10 Managed Nodes)"
}'

curl --location --request POST 'https://localhost/api/v2/organizations/' \
--header 'Content-Type: application/json' \
--header 'Authorization: Basic e3t1c2VybmFtZX19Ont7cGFzc3dvcmR9fQ==' \
--data-raw '{
    "name": "CyberArk_hydration",
    "description": "Main Demo Organization",
    "max_hosts": 0,
    "custom_virtualenv": null
}'