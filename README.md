# Camunda with Aurora PostgreSQL to S3 replication demo

## Provision terraform infra
```
(cd terraform && terraform init)
(cd terraform && terraform apply)
```

## Start port forwarding SSH proxy
```
./port-forwarding.sh
```

## Start Camunda
```
./camunda/camunda-run/start.sh
```

## Start DMS DB -> S3 replication task
```
./start-dms-task.sh
```

## Verify that the task is running
https://us-west-1.console.aws.amazon.com/dms/v2/home?region=us-west-1#taskDetails/db-s3-replcation-task


## Demo scenario

Connect to database and list instance variable history
```
./pgcli.sh
SELECT * FROM act_hi_varinst
```

Sync target replication S3 bucket to local folder
```
./sync-s3.sh
```

Display Parquet full load file content
```
parquet cat parquet/public/act_hi_varinst/LOAD00000001.parquet | jq .
```

Clain and complete a task

http://localhost:8080/camunda/app/tasklist/default/

Re-sync S3

```
./sync-s3.sh
```

Display last continuously synced Parquet file
```
FILE=$(find parquet/public/act_hi_varinst/ -type f | grep -v LOAD | tail -n 1)
echo ${FILE}
parquet cat ${FILE} | jq .
```

NB: First column `Op` contains either `I` for `I`nsert or `U` for `U`pdate.

Connect to database and delete the instance variable history of a process instance
```
./pgcli.sh
SELECT proc_inst_id_ FROM act_hi_varinst LIMIT 1
DELETE FROM act_hi_varinst WHERE proc_inst_id_ = (SELECT proc_inst_id_ FROM act_hi_varinst LIMIT 1)
```

Re-sync S3

```
./sync-s3.sh
```

NB: There may be files synced because some inserts or updates may have happened but no deletes records should have happened.

Display last continuously synced Parquet file
```
FILE=$(find parquet/public/act_hi_varinst/ -type f | grep -v LOAD | tail -n 1)
echo ${FILE}
parquet cat ${FILE} | jq .
```

The last Parquet file should not contain any `D`eletes.
