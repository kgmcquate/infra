
resource "aws_db_instance" "default" {
  identifier = "lake-freeze-db"

  allocated_storage    = 10
  max_allocated_storage = 100
  db_name              = "lake_freeze"
  engine               = "postgres"
  engine_version       = "15.2"
  instance_class       = "db.t4g.micro"
  username             = local.db_username
  password             = local.db_password
  skip_final_snapshot  = true

  iam_database_authentication_enabled = true
  vpc_security_group_ids = [data.aws_security_group.default.id, aws_security_group.allow_all.id]
  multi_az = false
  publicly_accessible = true
  port = 5432

  
}