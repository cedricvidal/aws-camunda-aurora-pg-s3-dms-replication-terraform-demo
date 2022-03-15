#!/usr/bin/env bash
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd ${HERE} > /dev/null

terraform output -json | jq -r '@sh "export PGUSER=\(.cluster_master_username.value)\nexport PGPASSWORD=\(.cluster_master_password.value)\nexport PGHOST=\(.cluster_endpoint.value)\nexport PGPORT=\(.cluster_port.value)\nexport PGDATABASE=\(.cluster_database_name.value)\nexport EC2_INSTANCE_HOSTNAME=\(.aws_instance_hostname.value)"'

popd > /dev/null
