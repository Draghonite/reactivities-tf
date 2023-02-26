provider "aws" {
  region = "us-east-1"
}

resource "aws_lightsail_instance" "server1" {
    # TODO: parameterize REGION, ENV, AVAILABILITY_ZONE, BUNDLE_ID, 
    count = 1
    name = "Reactivities_dev_us-east-1-${count.index+1}"
    availability_zone = "us-east-1a"
    blueprint_id = "ubuntu_20_04"
    bundle_id = "nano_2_0"
    # user_data = "TODO: read in w/ new-line from <root>/assets/user_data.sh"
    tags = {
      "ApplicationId" = "Reactivities"
    }
}

output "server1_public_ip" {
  value = ["${aws_lightsail_instance.*.public_ip_address}"]
}