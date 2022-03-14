terraform output -json | jq -r '@sh "export PGUSER=\(.cluster_master_username.value)\nexport PGPASSWORD=\(.cluster_master_password.value)\nexport PGHOST=\(.cluster_endpoint.value)\nexport PGPORT=\(.cluster_port.value)"'
export PGDATABASE=demo
