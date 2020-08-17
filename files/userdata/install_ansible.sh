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
until $(curl -ikL --output /dev/null --silent --head --fail https://localhost/api/v2); do printf '.';sleep 5; done
#Configure License
curl -k -u admin:Cyberark1 --request POST 'https://localhost/api/v2/config/' --header 'Content-Type: application/json' --data-binary '{
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
#Configure Organization
ORGID=$(curl -k -u admin:Cyberark1 --request POST 'https://localhost/api/v2/organizations/' --header 'Content-Type: application/json' --data-binary '{"name": "CyberArk_hydration","description": "Main Demo Organization","max_hosts": 0,"custom_virtualenv": null}' | jq .id)
#Configure Team in Organization
cat > team <<EOF
{
    "name": "security_team",
    "description": "Team in charge of all credentials",
    "organization": "$ORGID"
}
EOF
TEAMID=$(curl -k -u admin:Cyberark1 --request POST 'https://localhost/api/v2/teams/' --header 'Content-Type: application/json' -d @team | jq .id)
rm team
#Configure AWS private Key
PRIV_KEY=$(cat ~/aws)
cat > aws_cred <<EOF
{
    "name": "aws_private_key",
    "description": "Private key to connect to aws instances",
    "organization": $ORGID,
    "credential_type": 1,
    "inputs": {"ssh_key_data":"$PRIV_KEY"},
    "user": null,
    "team": $TEAMID
}
EOF
CREDID=$(curl -k -u admin:Cyberark1 --request POST 'https://localhost/api/v2/credentials/' --header 'Content-Type: application/json' -d @aws_cred | jq .id)
rm aws_cred
#Configure invetory for leader instance
cat > inventory_leader <<EOF
{
    "name": "Conjur_Leader",
    "description": "All Conjur Master Systems",
    "organization": $ORGID,
    "kind": "",
    "host_filter": null,
    "variables": "---\nansible_user: ec2-user",
    "insights_credential": null
}
EOF
INVENTORYIDLEADER=$(curl -k -u admin:Cyberark1 --request POST 'https://localhost/api/v2/inventories/' --header 'Content-Type: application/json' -d @inventory_leader | jq .id)
rm inventory_leader
#Configure inventory source for leader instance
cat > inventory_source_leader <<EOF
{
    "name": "AWS",
    "description": "Conjur Leader nodes in AWS",
    "source": "ec2",
    "source_path": "",
    "source_script": null,
    "source_vars": "---\nvpc_destination_variable: private_ip_address",
    "credential": null,
    "source_regions": "all",
    "instance_filters": "tag-key=role,tag-value=hydration,tag-key=clusterrole,tag-value=leader",
    "group_by": "",
    "overwrite": true,
    "overwrite_vars": false,
    "custom_virtualenv": null,
    "timeout": 0,
    "verbosity": 1,
    "inventory": $INVENTORYIDLEADER,
    "update_on_launch": true,
    "update_cache_timeout": 0,
    "source_project": null,
    "update_on_project_update": false
}
EOF
INVENTORYSOURCEIDLEADER=$(curl -k -u admin:Cyberark1 --request POST 'https://localhost/api/v2/inventory_sources/' --header 'Content-Type: application/json' -d @inventory_source_leader | jq .id)
rm inventory_source_leader
#Configure inventory for standby instances
cat > inventory_standby <<EOF
{
    "name": "Conjur_Standbys",
    "description": "All Conjur Standby Systems",
    "organization": $ORGID,
    "kind": "",
    "host_filter": null,
    "variables": "---\nansible_user: ec2-user",
    "insights_credential": null
}
EOF
INVENTORYIDSTANDBY=$(curl -k -u admin:Cyberark1 --request POST 'https://localhost/api/v2/inventories/' --header 'Content-Type: application/json' -d @inventory_standby | jq .id)
rm inventory_standby
#Configure inventory source for standby instances
cat > inventory_source_standby <<EOF
{
    "name": "AWS",
    "description": "Conjur standby nodes in AWS",
    "source": "ec2",
    "source_path": "",
    "source_script": null,
    "source_vars": "---\nvpc_destination_variable: private_ip_address",
    "credential": null,
    "source_regions": "all",
    "instance_filters": "tag-key=role,tag-value=hydration,tag-key=clusterrole,tag-value=standby",
    "group_by": "",
    "overwrite": true,
    "overwrite_vars": false,
    "custom_virtualenv": null,
    "timeout": 0,
    "verbosity": 1,
    "inventory": $INVENTORYIDSTANDBY,
    "update_on_launch": true,
    "update_cache_timeout": 0,
    "source_project": null,
    "update_on_project_update": false
}
EOF
INVENTORYSOURCEIDSTANDBY=$(curl -k -u admin:Cyberark1 --request POST 'https://localhost/api/v2/inventory_sources/' --header 'Content-Type: application/json' -d @inventory_source_standby | jq .id)
rm inventory_source_standby
#Configure inventory for follower instances
cat > inventory_follower <<EOF
{
    "name": "Conjur_followers",
    "description": "All Conjur follower Systems",
    "organization": $ORGID,
    "kind": "",
    "host_filter": null,
    "variables": "---\nansible_user: ec2-user",
    "insights_credential": null
}
EOF
INVENTORYIDFOLLOWER=$(curl -k -u admin:Cyberark1 --request POST 'https://localhost/api/v2/inventories/' --header 'Content-Type: application/json' -d @inventory_follower | jq .id)
rm inventory_follower
#Configure inventory source for follower instances
cat > inventory_source_follower <<EOF
{
    "name": "AWS",
    "description": "Conjur follower nodes in AWS",
    "source": "ec2",
    "source_path": "",
    "source_script": null,
    "source_vars": "---\nvpc_destination_variable: private_ip_address",
    "credential": null,
    "source_regions": "all",
    "instance_filters": "tag-key=role,tag-value=hydration,tag-key=clusterrole,tag-value=follower",
    "group_by": "",
    "overwrite": true,
    "overwrite_vars": false,
    "custom_virtualenv": null,
    "timeout": 0,
    "verbosity": 1,
    "inventory": $INVENTORYIDFOLLOWER,
    "update_on_launch": true,
    "update_cache_timeout": 0,
    "source_project": null,
    "update_on_project_update": false
}
EOF
INVENTORYSOURCEIDFOLLOWER=$(curl -k -u admin:Cyberark1 --request POST 'https://localhost/api/v2/inventory_sources/' --header 'Content-Type: application/json' -d @inventory_source_follower | jq .id)
rm inventory_source_follower
#Configure project
SCM_BRANCH="conjur_config"
cat > project_conjur <<EOF
{
    "name": "Conjur",
    "description": "This Project will configure conjur instances.",
    "local_path": "",
    "scm_type": "git",
    "scm_url": "https://github.com/CaptainFluffyToes/awsPipeline.git",
    "scm_branch": "$SCM_BRANCH",
    "scm_refspec": "",
    "scm_clean": false,
    "scm_delete_on_update": false,
    "credential": null,
    "timeout": 0,
    "organization": $ORGID,
    "scm_update_on_launch": true,
    "scm_update_cache_timeout": 0,
    "allow_override": false,
    "custom_virtualenv": null
}
EOF
PROJECTCONJURID=$(curl -k -u admin:Cyberark1 --request POST 'https://localhost/api/v2/projects/' --header 'Content-Type: application/json' -d @project_conjur | jq .id)
rm project_conjur
STATUS="null"
while [[ "$STATUS" = "null" ]]
do
    STATUS=$(curl -sk -u admin:Cyberark1 --request GET "https://localhost/api/v2/projects/$PROJECTCONJURID/" | jq .last_job_run)
    echo "Successful!"
    sleep 1
done
#Configure template for leader configuration
cat > template_conjur_leader <<EOF
{
    "name": "Configure_Conjur_Leader",
    "description": "This template will configure the conjur leader instance.",
    "job_type": "run",
    "inventory": $INVENTORYIDLEADER,
    "project": $PROJECTCONJURID,
    "playbook": "conjur_leader.yml",
    "scm_branch": "",
    "forks": 0,
    "limit": "",
    "verbosity": 0,
    "extra_vars": "",
    "job_tags": "",
    "force_handlers": false,
    "skip_tags": "",
    "start_at_task": "",
    "timeout": 0,
    "use_fact_cache": false,
    "host_config_key": "",
    "ask_scm_branch_on_launch": false,
    "ask_diff_mode_on_launch": false,
    "ask_variables_on_launch": false,
    "ask_limit_on_launch": false,
    "ask_tags_on_launch": false,
    "ask_skip_tags_on_launch": false,
    "ask_job_type_on_launch": false,
    "ask_verbosity_on_launch": false,
    "ask_inventory_on_launch": false,
    "ask_credential_on_launch": false,
    "survey_enabled": false,
    "become_enabled": false,
    "diff_mode": false,
    "allow_simultaneous": false,
    "custom_virtualenv": null,
    "job_slice_count": 1,
    "webhook_service": null,
    "webhook_credential": null
}
EOF
#Add credentials to the template
TEMPLATECONJURLEADERID=$(curl -k -u admin:Cyberark1 --request POST 'https://localhost/api/v2/job_templates/' --header 'Content-Type: application/json' -d @template_conjur_leader | jq .id)
rm template_conjur_leader
cat > template_cred <<EOF
{
    "associate": true,
    "id": $CREDID
}
EOF
OUTPUTID=$(curl -k -u admin:Cyberark1 --request POST "https://localhost/api/v2/job_templates/$TEMPLATECONJURLEADERID/credentials/" --header 'Content-Type: application/json' -d @template_cred | jq)
#Configure template for follower configuration
cat > template_conjur_follower <<EOF
{
    "name": "Configure_Conjur_Follower",
    "description": "This template will configure the conjur follower instances.",
    "job_type": "run",
    "inventory": $INVENTORYIDFOLLOWER,
    "project": $PROJECTCONJURID,
    "playbook": "conjur_follower.yml",
    "scm_branch": "",
    "forks": 0,
    "limit": "",
    "verbosity": 0,
    "extra_vars": "",
    "job_tags": "",
    "force_handlers": false,
    "skip_tags": "",
    "start_at_task": "",
    "timeout": 0,
    "use_fact_cache": false,
    "host_config_key": "",
    "ask_scm_branch_on_launch": false,
    "ask_diff_mode_on_launch": false,
    "ask_variables_on_launch": false,
    "ask_limit_on_launch": false,
    "ask_tags_on_launch": false,
    "ask_skip_tags_on_launch": false,
    "ask_job_type_on_launch": false,
    "ask_verbosity_on_launch": false,
    "ask_inventory_on_launch": false,
    "ask_credential_on_launch": false,
    "survey_enabled": false,
    "become_enabled": false,
    "diff_mode": false,
    "allow_simultaneous": false,
    "custom_virtualenv": null,
    "job_slice_count": 1,
    "webhook_service": null,
    "webhook_credential": null
}
EOF
#Add credentials to the template
TEMPLATECONJURFOLLOWERID=$(curl -k -u admin:Cyberark1 --request POST 'https://localhost/api/v2/job_templates/' --header 'Content-Type: application/json' -d @template_conjur_follower | jq .id)
rm template_conjur_follower
OUTPUTID=$(curl -k -u admin:Cyberark1 --request POST "https://localhost/api/v2/job_templates/$TEMPLATECONJURFOLLOWERID/credentials/" --header 'Content-Type: application/json' -d @template_cred | jq)
#Configure template for standby configuration
cat > template_conjur_standby <<EOF
{
    "name": "Configure_Conjur_Standby",
    "description": "This template will configure the conjur follower instances.",
    "job_type": "run",
    "inventory": $INVENTORYIDSTANDBY,
    "project": $PROJECTCONJURID,
    "playbook": "conjur_standby.yml",
    "scm_branch": "",
    "forks": 0,
    "limit": "",
    "verbosity": 0,
    "extra_vars": "",
    "job_tags": "",
    "force_handlers": false,
    "skip_tags": "",
    "start_at_task": "",
    "timeout": 0,
    "use_fact_cache": false,
    "host_config_key": "",
    "ask_scm_branch_on_launch": false,
    "ask_diff_mode_on_launch": false,
    "ask_variables_on_launch": false,
    "ask_limit_on_launch": false,
    "ask_tags_on_launch": false,
    "ask_skip_tags_on_launch": false,
    "ask_job_type_on_launch": false,
    "ask_verbosity_on_launch": false,
    "ask_inventory_on_launch": false,
    "ask_credential_on_launch": false,
    "survey_enabled": false,
    "become_enabled": false,
    "diff_mode": false,
    "allow_simultaneous": false,
    "custom_virtualenv": null,
    "job_slice_count": 1,
    "webhook_service": null,
    "webhook_credential": null
}
EOF
#Add credentials to the template
TEMPLATECONJURSTANDBYID=$(curl -k -u admin:Cyberark1 --request POST 'https://localhost/api/v2/job_templates/' --header 'Content-Type: application/json' -d @template_conjur_standby | jq .id)
rm template_conjur_standby
OUTPUTID=$(curl -k -u admin:Cyberark1 --request POST "https://localhost/api/v2/job_templates/$TEMPLATECONJURSTANDBYID/credentials/" --header 'Content-Type: application/json' -d @template_cred | jq)
#Launch conjur leader job template
curl -sk -u admin:Cyberark1 --request POST "https://localhost/api/v2/job_templates/$TEMPLATECONJURLEADERID/launch/"