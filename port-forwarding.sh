eval $(./terraform/env.sh); ssh -N -i ~/.ssh/aws/demo-key-1.pem -L ${PGPORT}:${PGHOST}:${PGPORT} ubuntu@${EC2_INSTANCE_HOSTNAME}
