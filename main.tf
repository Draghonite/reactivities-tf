provider "aws" {
  region = var.region
}

variable "region" {
  type = string
}

variable "availability_zone" {
  type = string
}

variable "deploy_env" {
  type = string
  default = "dev"
}

variable "bundle_id" {
  type = string
  default = "nano_2_0"
}

variable "app_name" {
  type = string
  default = "Reactivities"
}

resource "aws_lightsail_key_pair" "lg_key_pair" {
    name = "lg_key_pair"
    public_key = file("assets/lg_key_pair.pub")
}

resource "aws_lightsail_instance" "app_server" {
  name = "${var.app_name}_${var.deploy_env}_${var.region}"
  availability_zone = var.availability_zone
  blueprint_id = "ubuntu_20_04"
  bundle_id = var.bundle_id
  user_data = "${file("assets/user_data.sh")}"
  key_pair_name = aws_lightsail_key_pair.lg_key_pair.name
  tags = {
    "ApplicationId" = var.app_name
  }
}

output "app_server_public_ips" {
  value = aws_lightsail_instance.app_server.public_ip_address
}