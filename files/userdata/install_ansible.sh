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
ORGID=$(curl -k -u admin:Cyberark1 --request POST 'https://localhost/api/v2/organizations/' --header 'Content-Type: application/json' --data-binary '{"name": "CyberArk_hydration","description": "Main Demo Organization","max_hosts": 0,"custom_virtualenv": null}' | jq .id)
cat > team <<EOF
{
    "name": "security_team",
    "description": "",
    "organization": "$ORGID"
}
EOF
TEAMID=$(curl -k -u admin:Cyberark1 --request POST 'https://localhost/api/v2/teams/' --header 'Content-Type: application/json' -d @team | jq .id)
cat > inventory_leader <<EOF
{
    "name": "Conjur_Leader",
    "description": "All Conjur Master Systems",
    "organization": $ORGID,
    "kind": "",
    "host_filter": null,
    "variables": "",
    "insights_credential": null
}
EOF
INVENTORYIDLEADER=$(curl -k -u admin:Cyberark1 --request POST 'https://localhost/api/v2/inventories/' --header 'Content-Type: application/json' -d @inventory_leader | jq .id)
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
cat > inventory_standby <<EOF
{
    "name": "Conjur_Standbys",
    "description": "All Conjur Standby Systems",
    "organization": $ORGID,
    "kind": "",
    "host_filter": null,
    "variables": "",
    "insights_credential": null
}
EOF
INVENTORYIDSTANDBY=$(curl -k -u admin:Cyberark1 --request POST 'https://localhost/api/v2/inventories/' --header 'Content-Type: application/json' -d @inventory_standby | jq .id)
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
cat > inventory_follower <<EOF
{
    "name": "Conjur_followers",
    "description": "All Conjur follower Systems",
    "organization": $ORGID,
    "kind": "",
    "host_filter": null,
    "variables": "",
    "insights_credential": null
}
EOF
INVENTORYIDFOLLOWER=$(curl -k -u admin:Cyberark1 --request POST 'https://localhost/api/v2/inventories/' --header 'Content-Type: application/json' -d @inventory_follower | jq .id)
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
cat > project_conjur_leader <<EOF
{
    "name": "Conjur_Leader",
    "description": "This Project will configure conjur leaders",
    "local_path": "",
    "scm_type": "git",
    "scm_url": "https://github.com/CaptainFluffyToes/awsPipeline.git",
    "scm_branch": "conjur_config",
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
PROJECTCONJURLEADERID=$(curl -k -u admin:Cyberark1 --request POST 'https://localhost/api/v2/projects/' --header 'Content-Type: application/json' -d @project_conjur_leader | jq .id)
cat > template_conjur_leader <<EOF
{
    "name": "Configure_Conjur_Leader",
    "description": "This template will configure the conjur ",
    "job_type": "run",
    "inventory": 4,
    "project": $PROJECTCONJURLEADERID,
    "playbook": "conjur.yml,
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
TEMPLATECONJURLEADERID=$(curl -k -u admin:Cyberark1 --request POST 'https://localhost/api/v2/job_templates/' --header 'Content-Type: application/json' -d @template_conjur_leader | jq .id)