
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

variable "tage=s" {
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


