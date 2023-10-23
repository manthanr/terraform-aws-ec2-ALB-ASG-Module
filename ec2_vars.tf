#Define Subnets to launch EC2 instance in
variable "ec2_subnet_ids" {
  type = list(string)
  default = ["subnet-000c33e9c1a714982","subnet-014ff9d8cfbe917d4"]
}

#Define Subnets to launch Application Load Balancer in
variable "lb_subnet_ids" {
  type = list(string)
  default = ["subnet-000c33e9c1a714982","subnet-014ff9d8cfbe917d4"]
}

#Define VPC to launch ALB Target Group in
variable "targetgroup_vpc" {
  type = string
  #default = "vpc-0bb418a558c3fxxxx"
}



#######

#Tag to apply to all resources 
variable "tag" {
    type = object({
        key = string
        value = string
        propagate_at_launch = bool
    })

    default = {
      key = "Name"
      value = "Terraform-Module-EC2"
      propagate_at_launch = true
    }
}


#######

#Define AMI to launch EC2 instance using
variable "ec2_ami" {
  type = string
  default = "amazon-linux-2"
}

#Instance Type
variable "ec2_type" {
  type = string
  default = "t3.micro"
}

#Instance Keypair
variable "keypair" {
    type = string
    default = "none"
}

#Security Group
variable "ec2_security_groups" {
    type = list(string)
    #default = ["sg-06f33b42f3cfexxx"]
}

#user-data script file 
variable user_data {
    type = string
    default = "./webserver.sh"
}

#######


#CPU value to scale using
variable "scalingtreshold" {
    type = number
    default = 70
}

#Minimum number of instances in Auto Scaling Group 
variable "min_instances" {
    type = number
    default = 2
}

#Maximum number of instances in Auto Scaling Group 
variable "max_instances" {
    type = number
    default = 4
}

#Desired Capacity for instances in Auto Scaling Group
variable "desired_capacity" {
    type = number
    default = 2
}

#Scaling Policy name
variable "ec2_scaling_policy_group_name" {
    type = string 
    default = "Terraform-EC2-Scaling-Policy"
}


#######

#Should a Load Balancer and necessary target groups be deployed?
variable "launchlb" {
    type = bool 
    default = true
}


#Security Group
variable "lb_security_groups" {
  type = list(string)
  #default = ["sg-06f33b42f3cfexxx"]
}

#Internal or External LB?
variable "lb_internal" {
  type = bool 
  default = false
}

#LB HTTPS?
variable "lb_HTTPS" {
  type = bool 
  default = false
}

#Target Group HTTPS?
variable "target_HTTPS" {
  type = bool
  default = false 
}

#Amazon Certificate Name
variable "ACN_ARN" {
  type = string
  default = "xxx" 
}
