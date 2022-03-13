# Create Database Subnet Group
# terraform aws db subnet group
resource "aws_db_subnet_group" "demo-database-subnet-group-1" {
    name         = "demo-database-subnet-group-1"
    subnet_ids   = [aws_subnet.demo-subnet-public-1.id, aws_subnet.demo-subnet-public-2.id]
    description  = "Subnets for Demo Database Instance 1"

    tags   = {
        Name = "demo-database-subnet-group-1"
    }
}

# Get the Latest DB Snapshot
# terraform aws data db snapshot
#data "aws_db_snapshot" "latest-db-snapshot" {
#    db_snapshot_identifier = "${var.demo-database-snapshot-identifier}"
#    most_recent            = true
#    snapshot_type          = "manual"
#}

# Create Database Instance Restored from DB Snapshots
# terraform aws db instance
resource "aws_db_instance" "database-instance" {
    instance_class          = "${var.demo-database-instance-class}"
    allocated_storage       = 10
    skip_final_snapshot     = true
    availability_zone       = "us-west-1a"
    identifier              = "demo-db-1"
#    snapshot_identifier     = data.aws_db_snapshot.latest-db-snapshot.id
    db_subnet_group_name    = aws_db_subnet_group.demo-database-subnet-group-1.name
    multi_az                = false
    vpc_security_group_ids  = [aws_security_group.demo-sg-1.id]
}
