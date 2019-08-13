module "vpc" {
  # This module creates VPC, subnets private and public inside it, NAT gataways and route tables.
  source = "terraform-aws-modules/vpc/aws"

  name = "consul-vpc"
  cidr = "192.168.0.0/24"
  # Private subnets
  azs                   = ["us-east-1a"]
  private_subnets       = ["192.168.0.0/26"]
  private_subnet_suffix = "private_"
  # Public subnets
  public_subnets       = ["192.168.0.64/26"]
  public_subnet_suffix = "public_"

  enable_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "consul-VPC"
  }
}


resource "aws_security_group_rule" "ssh_allow" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpc.default_security_group_id
  description       = "allowing inbound ssh connectivity"
}

data "aws_ami" "ami_details" {
  #executable_users = ["self"]
  most_recent = true
  name_regex  = "^packer-consul-\\d{10}"
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["packer-consul-*"]
  }
}

# Generates public and private key to be used for the keypair
# The private key to connect to the EC2 is saved in PROJECT_ROOT/private_keys
module "generate_keys" {
  source   = "./modules/generate_keys"
  key_name = "consul_server_key"

}
# Creates Consul server
module "consul_server" {
  source = "./modules/consul_server"

  # Run this particular Ubuntu AMI
  ami = data.aws_ami.ami_details.image_id
  # Subnet ID this instance to be associated with.
  subnet_id = module.vpc.public_subnets[0]
  # What SGs to apply to this instance
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  # ID of the key pair to be used to access this instance
  key_name = module.generate_keys.key_name
  #Public key to be used.
  public_key_ssh = module.generate_keys.public_key_ssh
  # Datacenter name
  datacenter = "dc-east"
}
