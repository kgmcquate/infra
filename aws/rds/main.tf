resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = var.subnet_ids
}


resource "aws_db_instance" "default" {
  identifier = "main-db"

  allocated_storage    = 10
  max_allocated_storage = 100
  db_name              = "main"
  engine               = "postgres"
  engine_version       = "15.5"
  instance_class       = "db.t4g.micro"
  username             = local.db_username
  password             = local.db_password
  skip_final_snapshot  = true

  iam_database_authentication_enabled = true
  db_subnet_group_name = aws_db_subnet_group.default.name
  vpc_security_group_ids = var.security_group_ids
  multi_az = false
  publicly_accessible = true
  port = 5432
}

