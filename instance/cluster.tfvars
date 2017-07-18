# AWS Settings
aws = {
  region         = "us-west-2"
  key_name       = "CyanideTD"                       
  ami            = "ami-d75444ae"                      
  subnet_id      = "subnet-ade9c3e4"
  subnet_ids     = "subnet-ade9c3e4,subnet-d7d9f89e"
  route53_zone   = "ZF740RJTWBCSE"
  monitoring     = "false"
  vpc_id         = "vpc-ec17ea8a"
  associate_public_ip_address = "true"
  in_ssh_cidr_block    = "0.0.0.0/0"
  iam_instance_profile = "worker"
  use_load_balancer    = false
}

# Terraform Settings
terraform = {
  backend = "s3"
  region  = "us-west-2"
  bucket  = "cyanide-us-west-2" # TODO
}

# Tags
tags = {
  environment = "taxi"
  user        = "cyanide"       # TODO
}

# Web Server Settings
webserver = {
  instance_type        = "t2.micro"
  count                = "1"
  root_volume_type     = "gp2"
  root_volume_size     = "8"
  in_http_cidr_block   = "0.0.0.0/0"
}

# Mapper Settings
mapper = {
  instance_type        = "c4.8xlarge"
  count                = "0"
  ebs_device_name      = "/dev/sdb"
  ebs_volume_size      = 2
  ebs_volume_type      = "gp2"
  ebs_volume_deletion  = "true"
  out_sqs_cidr_block   = "0.0.0.0/0"

  use_as_ecs           = false
}

# Docker Settings
docker = {
  ami                  = "ami-12b23172"
  instance_type        = "t2.micro"
  count                = "0"
}

