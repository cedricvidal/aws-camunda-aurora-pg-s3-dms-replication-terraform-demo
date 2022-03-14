module "cluster" {
  source  = "terraform-aws-modules/rds-aurora/aws"

  name           = "demo-aurora-db-postgres-1"
  engine         = "aurora-postgresql"
  engine_version = "11.12"
  instance_class = "db.r6g.large"
  instances = {
    one = {}
    two = {}
  }

  vpc_id  = "${aws_vpc.demo-vpc-1.id}"
  subnets = ["${aws_subnet.demo-subnet-public-1.id}", "${aws_subnet.demo-subnet-public-2.id}"]

  #allowed_security_groups = [aws_security_group.demo-sg-1.id]
  allowed_cidr_blocks     = ["${aws_vpc.demo-vpc-1.cidr_block}"]

  storage_encrypted   = true
  apply_immediately   = true
  monitoring_interval = 10

  db_parameter_group_name         = "${aws_db_parameter_group.demo-aurora-db-postgres11-parameter-group.name}"
  db_cluster_parameter_group_name = "${aws_rds_cluster_parameter_group.demo-rds-cluster-parameter-group-1.name}"

  enabled_cloudwatch_logs_exports = ["postgresql"]

  # Disable creation of random password - AWS API provides the password
  create_random_password = false

  master_username = "demo"
  master_password = "th1s1s2d3m0Dms"

  # Disable creation of subnet group - provide a subnet group
  create_db_subnet_group = true

  # Disable creation of security group - provide a security group
  create_security_group = true

#  vpc_security_group_ids = [module.cluster.security_group_id]

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

output "security_group_id" {
    value = "${module.cluster.security_group_id}"
}

resource "aws_db_parameter_group" "demo-aurora-db-postgres11-parameter-group" {
  name        = "demo-aurora-db-postgres11-parameter-group"
  family      = "aurora-postgresql11"
  description = "demo-aurora-db-postgres11-parameter-group"
  tags        = {
      Name = "demo-aurora-db-postgres11-parameter-group"
  }
}

resource "aws_rds_cluster_parameter_group" "demo-rds-cluster-parameter-group-1" {
  name        = "demo-aurora-postgres11-cluster-parameter-group"
  family      = "aurora-postgresql11"
  description = "demo-aurora-postgres11-cluster-parameter-group"
  tags        = {
      Name = "demo-aurora-postgres11-cluster-parameter-group"
  }
}
