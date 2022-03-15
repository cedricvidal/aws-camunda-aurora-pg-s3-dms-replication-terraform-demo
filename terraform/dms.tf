# Database Migration Service requires the below IAM Roles to be created before
# replication instances can be created. See the DMS Documentation for
# additional information: https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Security.html#CHAP_Security.APIRole
#  * dms-vpc-role
#  * dms-cloudwatch-logs-role
#  * dms-access-for-endpoint

data "aws_iam_policy_document" "dms_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["dms.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "dms-access-for-endpoint" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-access-for-endpoint"
}

resource "aws_iam_role_policy_attachment" "dms-access-for-endpoint-AmazonDMSRedshiftS3Role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSRedshiftS3Role"
  role       = aws_iam_role.dms-access-for-endpoint.name
}

resource "aws_iam_role" "dms-cloudwatch-logs-role" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-cloudwatch-logs-role"
}

resource "aws_iam_role_policy_attachment" "dms-cloudwatch-logs-role-AmazonDMSCloudWatchLogsRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
  role       = aws_iam_role.dms-cloudwatch-logs-role.name
}

resource "aws_iam_role" "dms-vpc-role" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-vpc-role"
}

resource "aws_iam_role_policy_attachment" "dms-vpc-role-AmazonDMSVPCManagementRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
  role       = aws_iam_role.dms-vpc-role.name
}

# Create a new replication instance
resource "aws_dms_replication_instance" "test" {
  allocated_storage            = 20
  apply_immediately            = true
  auto_minor_version_upgrade   = true
  availability_zone            = "us-west-1a"
  engine_version               = "3.4.3"
  multi_az                     = false
  preferred_maintenance_window = "sun:10:30-sun:14:30"
  publicly_accessible          = false
  replication_instance_class   = "dms.t2.micro"
  replication_instance_id      = "test-dms-replication-instance-tf"
  replication_subnet_group_id  = aws_dms_replication_subnet_group.test-dms-replication-subnet-group-tf.id

  tags = {
    Name = "test"
  }

  vpc_security_group_ids = [
    aws_security_group.demo-sg-1.id,
  ]

  depends_on = [
    aws_iam_role_policy_attachment.dms-access-for-endpoint-AmazonDMSRedshiftS3Role,
    aws_iam_role_policy_attachment.dms-cloudwatch-logs-role-AmazonDMSCloudWatchLogsRole,
    aws_iam_role_policy_attachment.dms-vpc-role-AmazonDMSVPCManagementRole
  ]
}

# Create a new replication subnet group
resource "aws_dms_replication_subnet_group" "test-dms-replication-subnet-group-tf" {
  replication_subnet_group_description = "Test replication subnet group"
  replication_subnet_group_id          = "test-dms-replication-subnet-group-tf"

  subnet_ids = [
    aws_subnet.demo-subnet-public-1.id,
    aws_subnet.demo-subnet-public-2.id
  ]

  tags = {
    Name = "test-dms-replication-subnet-group-tf"
  }
}

# Create source database endpoint
resource "aws_dms_endpoint" "db-dms-source-endpoint" {
  #certificate_arn             = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
  database_name               = var.demo-database-name
  endpoint_id                 = "db-dms-source-endpoint"
  endpoint_type               = "source"
  engine_name                 = "aurora-postgresql"

  # https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Source.PostgreSQL.html#CHAP_Source.PostgreSQL.ConnectionAttrib
  extra_connection_attributes = "captureDDLs=N"

  #kms_key_arn                 = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  server_name                 = module.cluster.cluster_reader_endpoint
  port                        = var.demo-database-port
  username                    = var.demo-database-username
  password                    = var.demo-database-password
  ssl_mode                    = "none"

  tags = {
    Name = "test"
  }
}

resource "aws_iam_role" "dms-s3-role" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-s3-role"
}

resource "aws_iam_role_policy_attachment" "dms-s3-role-AmazonS3FullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.dms-access-for-endpoint.name
}

# Create source database endpoint
resource "aws_dms_endpoint" "s3-dms-target-endpoint" {
  #certificate_arn             = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
  endpoint_id                 = "s3-dms-target-endpoint"
  endpoint_type               = "target"
  engine_name                 = "s3"
  extra_connection_attributes = ""
  #kms_key_arn                 = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

  s3_settings {
      bucket_name             = aws_s3_bucket.dms-target-s3-bucket.bucket

      # (Optional) Output format for the files that AWS DMS uses to create S3 objects. Valid values are csv and parquet. Default is csv.
      data_format             = "parquet"

      # parquet_version - (Optional) Version of the .parquet file format. Default is parquet-1-0. Valid values are parquet-1-0 and parquet-2-0.
      parquet_version         = "parquet-1-0"

      # (Optional) Whether to write insert and update operations to .csv or .parquet output files. Default is false.
      cdc_inserts_and_updates = true

      # (Optional) Maximum length of the interval, defined in seconds, after which to output a file to Amazon S3. Default is 60.
      cdc_max_batch_interval  = 30

      # (Optional) Minimum file size, defined in megabytes, to reach for a file output. Default is 32.
      cdc_min_file_size       = 1

      # preserve_transactions - (Optional) Whether DMS saves the transaction order for a CDC load on the S3 target specified by cdc_path. Default is false.
      preserve_transactions   = false

      # service_access_role_arn - (Optional) ARN of the IAM Role with permissions to read from or write to the S3 Bucket.
      service_access_role_arn = aws_iam_role.dms-s3-role.arn
  }

  tags = {
    Name = "test"
  }

}

data "template_file" "dms-camunda-history-table-mappings" {
  template = "${file("${path.module}/table-mappings/camunda-history-table-mappings.json")}"
}

# Create a new replication task
resource "aws_dms_replication_task" "db-s3-replcation-task" {

  # migration_type - (Required) The migration type. Can be one of full-load | cdc | full-load-and-cdc.
  migration_type            = "full-load-and-cdc"

  # replication_instance_arn - (Required) The Amazon Resource Name (ARN) of the replication instance.
  replication_instance_arn  = aws_dms_replication_instance.test.replication_instance_arn

  # replication_task_id - (Required) The replication task identifier.
  replication_task_id       = "db-s3-replcation-task"

  # replication_task_settings - (Optional) An escaped JSON string that contains the task settings. For a complete list of task settings, see Task Settings for AWS Database Migration Service Tasks.
  # replication_task_settings = "..."

  source_endpoint_arn       = aws_dms_endpoint.db-dms-source-endpoint.endpoint_arn
  table_mappings            = data.template_file.dms-camunda-history-table-mappings.rendered

  target_endpoint_arn = aws_dms_endpoint.s3-dms-target-endpoint.endpoint_arn

  tags = {
    Name = "test"
  }

}
