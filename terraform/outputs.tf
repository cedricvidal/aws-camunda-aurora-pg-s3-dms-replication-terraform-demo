output "cluster_port" {
  description = "The database port"
  value       = module.cluster.cluster_port
}
output "cluster_master_username" {
  description = "The database master username"
  value       = module.cluster.cluster_master_username
  sensitive   = true
}

output "cluster_master_password" {
  description = "The database master password"
  value       = module.cluster.cluster_master_password
  sensitive   = true
}

output "cluster_endpoint" {
  description = "Writer endpoint for the cluster"
  value       = module.cluster.cluster_endpoint
}

output "cluster_reader_endpoint" {
  description = "A read-only endpoint for the cluster, automatically load-balanced across replicas"
  value       = module.cluster.cluster_reader_endpoint
}

output "cluster_database_name" {
  description = "Name for an automatically created database on cluster creation"
  value       = module.cluster.cluster_database_name
}

output "aws_instance_hostname" {
  value = aws_instance.demo-instance-1.public_dns
}
