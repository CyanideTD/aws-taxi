# Terraform Configurations

variable "aws" {
    type = "map"
    default = {
        region = ""
	ami = ""
	key_name = ""
	route53_zone = ""
	security_group = ""
	subnet_id = ""
	subnet_ids = ""
	monitoring = ""
	vpc_id = ""
	asssociate_public_ip_address = ""
	iam_instance_profile = ""
	in_ssh_cidr_block = ""
	use_load_balancer = ""
    }
}

variable "terraform" {
    type = "map"
    default = {
        backend = ""
	region = ""
	bucket = ""
    }
}

variable "tags" {
    type = "map"
    default = {
	environment = ""
	user = ""
    }
}

variable "webserver" {
    type = "map"
    default = {
	instance_type = ""
	count = ""
	root_volume_type = ""
	root_volume_size = ""
	root_volume_delete = ""
	in_http_cidr_block = ""
    }
}

variable "mapper" {
    type = "map"
    default = {
	instance_type = ""
	count = 0
	ebs_device_name = ""
	ebs_volume_size = ""
	ebs_volume_type = ""
	ebs_volume_deletion = ""
	use_as_ecs = ""
    }
}

variable "docker" {
    type = "map"
    default = {
	ami           = ""
        instance_type = ""
        count         = 0
    }
}

provider "aws" {
    region = "${var.aws["region"]}"
}

### Security Group ###
resource "aws_security_group" "default" {
    vpc_id = "${var.aws["vpc_id"]}"
    name = "default-security-group-${var.tags["environment"]}"
    description = "default security group in ${var.tags["environment"]}"

    # Allow all traffic within the default group
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        self = "true"
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        self = "true"
    }

    # Allow inbound SSH
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.aws["in_ssh_cidr_block"]}"]
    }

    # Allow all outbound
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        Environment = "${var.tags["environment"]}"
        Name        = "default-security-group-${var.tags["environment"]}"
    }

}

resource "aws_security_group" "webserver" {
    vpc_id = "${var.aws["vpc_id"]}"
    name = "webserver-security-group-${var.tags["environment"]}"
    description = "webserver security group in ${var.tags["environment"]}"

    // allow inbound HTTP
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [ "${var.webserver["in_http_cidr_block"]}" ]
    }

    ingress {
        from_port = 5006
        to_port = 5006
        protocol = "tcp"
        cidr_blocks = [ "${var.webserver["in_http_cidr_block"]}" ]
    }

    tags {
        Environment = "${var.tags["environment"]}"
        User        = "${var.tags["user"]}"
        Name = "webserver-security-group-${var.tags["environment"]}"
    }
}

resource "aws_security_group" "mapper" {
    vpc_id = "${var.aws["vpc_id"]}"
    name = "mapper-security-group-${var.tags["environment"]}"
    description = "mapper security group in ${var.tags["environment"]}"

    // allow outbound to SQS
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["${var.mapper["out_sqs_cidr_block"]}"]
    }

    tags {
        Environment = "${var.tags["environment"]}"
        User        = "${var.tags["user"]}"
        Name        = "mapper-security-group-${var.tags["environment"]}"
    }
}



### EC2 Resources ###

# Web Server
resource "aws_instance" "webserver" {
    ami                         = "${var.aws["ami"]}"
    vpc_security_group_ids      = ["${aws_security_group.default.id}", "${aws_security_group.webserver.id}"]
    subnet_id			= "${var.aws["subnet_id"]}"
    key_name			= "${var.aws["key_name"]}"
    monitoring			= "${var.aws["monitoring"]}"
    associate_public_ip_address = "${var.aws["associate_public_ip_address"]}"
    iam_instance_profile	= "${var.aws["iam_instance_profile"]}"
    instance_type		= "${var.webserver["instance_type"]}"
    count			= "${var.webserver["count"]}"
    root_block_device {
        volume_type = "${var.webserver["root_volume_type"]}"
        volume_size = "${var.webserver["root_volume_size"]}"
        delete_on_termination = "${var.webserver["root_volume_delete"]}"
    }

    tags {
        Environment = "${var.tags["environment"]}"
        User        = "${var.tags["user"]}"
        Group       = "webserver"
        Name        = "webserver${count.index}"
    }

}

# Mapper
resource "aws_instance" "mapper" {
    ami                         = "${var.aws["ami"]}"
    vpc_security_group_ids      = [ "${aws_security_group.default.id}", "${aws_security_group.mapper.id}" ]
    subnet_id                   = "${var.aws["subnet_id"]}"
    key_name                    = "${var.aws["key_name"]}"
    monitoring                  = "${var.aws["monitoring"]}"
    associate_public_ip_address = "${var.aws["associate_public_ip_address"]}"
    iam_instance_profile        = "${var.aws["iam_instance_profile"]}"

    instance_type               = "${var.mapper["instance_type"]}"
    count                       = "${var.mapper["count"]}"

    #ebs_block_device {
    #    device_name = "${var.mapper["ebs_device_name"]}"
    #    volume_size = "${var.mapper["ebs_volume_size"]}"
    #    volume_type = "${var.mapper["ebs_volume_type"]}"
    #    delete_on_termination = "${var.mapper["ebs_volume_deletion"]}"
    #}

    tags {
        Environment = "${var.tags["environment"]}"
        User        = "${var.tags["user"]}"
        Group       = "mapper"
        Name        = "mapper${count.index}"
    }
}


# Docker
resource "aws_instance" "docker" {
    ami                         = "${var.docker["ami"]}"
    vpc_security_group_ids      = [ "${aws_security_group.default.id}", "${aws_security_group.mapper.id}" ]
    subnet_id                   = "${var.aws["subnet_id"]}"
    key_name                    = "${var.aws["key_name"]}"
    monitoring                  = "${var.aws["monitoring"]}"
    associate_public_ip_address = "${var.aws["associate_public_ip_address"]}"
    iam_instance_profile        = "${var.aws["iam_instance_profile"]}"

    instance_type               = "${var.docker["instance_type"]}"
    count                       = "${var.docker["count"]}"

    tags {
        Environment = "${var.tags["environment"]}"
        User        = "${var.tags["user"]}"
        Group       = "docker"
        Name        = "docker${count.index}"
    }
}

resource "aws_ecs_task_definition" "mapper" {
    count = "${var.mapper["use_as_ecs"] ? 1 : 0}"
    family = "mapper-ecs-service"
    container_definitions = "${file("mapper.json")}"
}

resource "aws_ecs_service" "mapper" {
        count = "${var.mapper["use_as_ecs"] ? 1 : 0}"
        name = "mapper-ecs-service"
        cluster = "${aws_ecs_cluster.mapper.id}"
        task_definition = "${aws_ecs_task_definition.mapper.arn}"
        desired_count = 1

        placement_strategy {
        type = "binpack"
        field = "cpu"
        }
}

resource "aws_ecs_cluster" "mapper" {
        count = "${var.mapper["use_as_ecs"] ? 1 : 0}"
        name = "mapper-ecs-cluster"
}

### ELB ###
resource "aws_alb" "web" {
    name = "webserver-alb-${var.tags["environment"]}"
    internal = false
    subnets = ["${split(",", var.aws["subnet_ids"])}"]
    security_groups = ["${aws_security_group.default.id}", "${aws_security_group.webserver.id}"]
    enable_deletion_protection = false
    count = "${(var.aws["use_load_balancer"] && var.webserver["count"] > 0) ? 1 : 0}"
    
    tag {
      Environment = "${var.tags["environment"]}"
      User        = "${var.tags["user"]}"
      Name        = "webserver-alb-${var.tags["environment"]}"
    }
}

resource "aws_alb_target_group" "web" {
  name     = "web${count.index}-target-group"
  port     = 80
  protocol = "HTTP"
  count    = "${var.aws["use_load_balancer"] ? var.webserver["count"] : 0}"
  vpc_id = "${var.aws["vpc_id"]}"
}

resource "aws_alb_target_group_attachment" "web" {
    count = "${var.aws["use_load_balancer"] ? var.webserver["count"] : 0}"
    target_group_arn = "${element(aws_alb_target_group.web.*.arn, count.index)}"
    target_id        = "${element(aws_instance.webserver.*.id, count.index)}"
    port = 80
}

resource "aws_alb_listener" "web" {
  load_balancer_arn = "${aws_alb.web.id}"
  port              = "80"
  protocol          = "HTTP"
  count             = "${(var.aws["use_load_balancer"] && var.webserver["count"] > 0) ? 1 : 0}"

  default_action {
    target_group_arn = "${element(aws_alb_target_group.web.*.arn, 0)}"
    type             = "forward"
  }
}

resource "aws_alb_listener_rule" "web" {
  listener_arn = "${aws_alb_listener.web.arn}"
  count        = "${var.aws["use_load_balancer"] ? var.webserver["count"] : 0}"
  priority     = "${count.index + 100}"

  action {
    type = "forward"
    target_group_arn = "${element(aws_alb_target_group.web.*.arn, count.index)}"
  }

  condition {
    field = "path-pattern"
    values = ["/webserver${count.index}/*"]
  }
}

### Route 53 Records ###
resource "aws_route53_record" "webserver" {
    zone_id = "${var.aws["route53_zone"]}"
    count   = "${var.webserver["count"]}"
    name    = "${element(aws_instance.webserver.*.tags.Name, count.index)}"
    type    = "A"
    ttl     = "300"
    records = ["${element(aws_instance.webserver.*.public_ip, count.index)}"]
}

resource "aws_route53_record" "web" {
    zone_id = "${var.aws["route53_zone"]}"
    count   = "${(! var.aws["use_load_balancer"] && var.webserver["count"] > 0) ? 1 : 0}"
    name    = "web"
    type    = "CNAME"
    ttl     = "300"
    records = ["${element(aws_route53_record.webserver.*.fqdn, 0)}"]
}

resource "aws_route53_record" "web_elb" {
    zone_id = "${var.aws["route53_zone"]}"
    count   = "${(var.aws["use_load_balancer"] && var.webserver["count"] > 0) ? 1 : 0}"
    name    = "web"
    type    = "CNAME"
    ttl     = "300"
    records = ["${aws_alb.web.dns_name}"]
}

resource "aws_route53_record" "mapper" {
    zone_id = "${var.aws["route53_zone"]}"
    count   = "${var.mapper["count"]}"
    name    = "${element(aws_instance.mapper.*.tags.Name, count.index)}"
    type    = "A"
    ttl     = "300"
    records = ["${element(aws_instance.mapper.*.public_ip, count.index)}"]
}

resource "aws_route53_record" "docker" {
    zone_id = "${var.aws["route53_zone"]}"
    count   = "${var.docker["count"]}"
    name    = "${element(aws_instance.docker.*.tags.Name, count.index)}"
    type    = "A"
    ttl     = "300"
    records = ["${element(aws_instance.docker.*.public_ip, count.index)}"]
}

### Output ###
output "webservers"  {
    value = ["${aws_route53_record.webserver.*.fqdn}"]
}

output "mappers" {
    value = ["${aws_route53_record.mapper.*.fqdn}"]
}

output "dockers" {
    value = ["${aws_route53_record.docker.*.fqdn}"]
}

