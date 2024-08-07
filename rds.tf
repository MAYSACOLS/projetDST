resource "aws_db_subnet_group" "mariadb_subnet_group" {
  name       = "mariadb-subnet-group"
  subnet_ids = var.database_subnets

  tags = {
    Name = "mariadb-subnet-group"
  }
}
#Configuration de l'Instance RDS
resource "aws_db_instance" "mariadb" {
  identifier           = "mariadb-instance"  # Nom de l'instance
  engine               = "mariadb"
  allocated_storage    =  20
  engine_version       = "10.5"
  instance_class       = "db.t3.micro"
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mariadb10.5"
  vpc_security_group_ids = ["${aws_security_group.sg_mariadb.id}"]
  skip_final_snapshot  = true
  publicly_accessible =  true
  db_name              = "wordpress"
  db_subnet_group_name = aws_db_subnet_group.mariadb_subnet_group.name
  tags = {
    Name = "database-mariadb"
  }
}
