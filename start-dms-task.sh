eval $(./terraform/env.sh); aws dms start-replication-task --start-replication-task-type start-replication --replication-task-arn ${DMS_TASK_ARN}
