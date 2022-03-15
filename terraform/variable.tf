variable "demo-database-instance-class" {
  default = "db.t2.micro"
  description = "The database instance class"
  type = string
}

variable "demo-database-username" {
  default = "demo"
  description = "The database username"
  type = string
}

variable "demo-database-password" {
  default = "th1s1s2d3m0Dms"
  description = "The database password"
  type = string
}

variable "demo-database-name" {
  default = "demo"
  description = "The database name"
  type = string
}

variable "demo-database-port" {
  default = "5432"
  description = "The database port"
  type = number
}
