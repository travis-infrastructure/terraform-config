module "aws_az_1b" {
  source = "../modules/aws_az"

  az = "1b"
  bastion_ami = "${var.aws_bastion_ami}"
  bastion_config = "${file("${path.module}/config/bastion-env")}"
  env = "${var.env}"
  gateway_id = "${aws_internet_gateway.gw.id}"
  nat_ami = "${var.aws_nat_ami}"
  nat_instance_type = "c3.large" # NOTE: production is c3.8xlarge
  public_subnet = "10.2.1.0/24"
  vpc_id = "${aws_vpc.main.id}"
  workers_com_subnet = "10.2.3.0/24"
  workers_org_subnet = "10.2.2.0/24"
}

module "aws_az_1e" {
  source = "../modules/aws_az"

  az = "1e"
  bastion_ami = "${var.aws_bastion_ami}"
  bastion_config = "${file("${path.module}/config/bastion-env")}"
  env = "${var.env}"
  gateway_id = "${aws_internet_gateway.gw.id}"
  nat_ami = "${var.aws_nat_ami}"
  nat_instance_type = "c3.large" # NOTE: production is c3.8xlarge
  public_subnet = "10.2.4.0/24"
  vpc_id = "${aws_vpc.main.id}"
  workers_com_subnet = "10.2.6.0/24"
  workers_org_subnet = "10.2.5.0/24"
}

module "aws_asg_org" {
  source = "../modules/aws_asg"

  cyclist_auth_tokens = "${var.cyclist_auth_tokens}"
  cyclist_debug = "true"
  cyclist_redis_plan = "hobby-dev"
  cyclist_scale = "web=1:Hobby"
  cyclist_version = "meat-logging"
  env = "${var.env}"
  heroku_org = "${var.aws_heroku_org}"
  index = "1"
  security_groups = "${module.aws_az_1b.workers_org_security_group_id},${module.aws_az_1e.workers_org_security_group_id}"
  site = "org"
  worker_ami = "${var.aws_worker_ami}"
  worker_asg_namespace = "Travis/org-staging"
  worker_asg_scale_in_threshold = "16"
  worker_asg_scale_out_threshold = "8"
  worker_config = "${file("${path.module}/config/worker-env-org")}"
  worker_subnets = "${module.aws_az_1b.workers_org_subnet_id},${module.aws_az_1e.workers_org_subnet_id}"
}

module "aws_asg_com" {
  source = "../modules/aws_asg"

  cyclist_auth_tokens = "${var.cyclist_auth_tokens}"
  cyclist_debug = "true"
  cyclist_redis_plan = "hobby-dev"
  cyclist_scale = "web=1:Hobby"
  cyclist_version = "meat-logging"
  env = "${var.env}"
  heroku_org = "${var.aws_heroku_org}"
  index = "1"
  security_groups = "${module.aws_az_1b.workers_com_security_group_id},${module.aws_az_1e.workers_com_security_group_id}"
  site = "com"
  worker_ami = "${var.aws_worker_ami}"
  worker_asg_namespace = "Travis/com-staging"
  worker_asg_scale_in_threshold = "16"
  worker_asg_scale_out_threshold = "8"
  worker_config = "${file("${path.module}/config/worker-env-com")}"
  worker_subnets = "${module.aws_az_1b.workers_com_subnet_id},${module.aws_az_1e.workers_com_subnet_id}"
}
