# Terraform Module - Deploy HA Auto Scaling Group Enabled EC2 Architecture

### Intro to module

In it's default configuration, this module creates an EC2 instance with HTTPD configured, along with an Auto Scale Group and a Load Balancer. Using the variables defined below, it is possible to modify the behaviour of the module to:

1. Not provision an Application Load Balancer
2. Change the user data script that is executed when the configuration is executed
3. Change the CPU Utilization % at which EC2 scaling occurs



### The variables this module takes as input:

**Subnets and VPCs:**

- `ec2_subnet_ids` **(Required)**: This variable defines which subnets EC2 instances will be deployed in by the Auto Scaling Group. The value here is provided in a ***list(string)*** format. For example: **["subnet-000c33e9c1axxx","subnet-014ff9d8cfbexxx"]**
- `lb_subnet_ids` ***(Required if ALB is created)***: Similar to `ec2_subnet_ids`, this variable expects a ***list(string)*** of subnets that the Application Load Balancer should be deployed on. The inclusion of this variable allows the ALB  to be deployed in a Public Subnet, while the EC2 instances are deployed in a Private Subnet

- `targetgroup_vpc` **(Required)**: This variable takes the VPC ID. This is required when Target Group being created has a *target_type* of Instance. The value expected here is a string:  ***vpc-0bb418a558c3xxx***



**Tag:**

- `tag` **(Optional)**: Where applicable, a Tag value is assigned to each resources created by the Terraform Module. By default, a tag is assigned with the **key** '*name*' and a **value** of '*Terraform-Module-EC2*-***.' Overwriting the tag variable allows a custom name prefix to be assigned to resources. This variable expects an object with the format:

  ```javascript
  {
    key = "Name"
    value = "Terraform-Module-EC2"
    propagate_at_launch = true
  
  }
  ```



**EC2 Instance Configuration:**

- `ec2-ami` **(Optional)**: By default, EC2 instances as a part of this Terraform module will be deployed using the Amazon Linux 2 AMI. A filter is used to select this AMI in the region that Terraform is creating resources in. The AMI can be overwritten for custom deployments with a string that represents the image id: ***ami-05163bdbbc24049e3***

- `ec2_type` **(Optional)**: The launch configuration leverages on-demand instances with a t3.micro size/type by default. This value can be overwritten by specifying a string with the instance type and size: ***m5.4xlarge***
- `keypair` **(Optional):** If no value is specified, the module deploys EC2 instances that are part of the Auto Scale Group (ASG) without a key-pair (the value of this variable is 'none'). Instances that are part of an ASG should be stateless, which supports this deployment choice. Users can specify a keypair by passing in a string with the appropriate keypair id: ***key-0939d2e92xxx***
- `ec2_security_groups` **(Required)**: A **list(string)** of Security Group IDs can be passed in this variable. In the case that the EC2 instances will be behind an Application Load Balancer, this security group should allow communication to the ALB: ***["sg-06f33b42f3cfexxxx"]***
- `user_data` **(Optional)**: A bash script is included with this module to install and configure HTTPD. However, users may overwrite the value of this variable to pass their own commands to execute during an instance's first invocation. If no commands need to be executed during the launch of an instance, pass the value 'none.' This variable takes a string: ***"./webserver.sh"*** or the value ***null***



**Auto Scale Group Configuration:**

- `scalingtreshold` **(Optional)**: The configuration is set to create an ASG which scales when the average CPU Utilization hits 70%. This value can be decreased by overwriting the variable with another integer: ***90***
- `min_instances` **(Optional)**: The minimum number of instances that the ASG should have at any time. Integer value: ***3***
- `max_instances` **(Optional)**: The maximum number of instances that the ASG should have at any time. Integer value: **5**
- `desired_capacity` **(Optional)**: The number of instances that the ASG should start with. Integer value: ***3***
- `ec2_scaling_policy_group_name` **(Optional)**: The name of the ASG Scaling Policy. String value: ***"Scaling-policy-x"***



**Load Balancer:**

- `launchlb` **(Optional)**: Should a Load Balancer be launched and attached to the EC2 ASG? Boolean value with default ***true***

- `lb_security_groups` (**Required**): The security groups that the ALB should leverage. Expects **list(string)** value. Even if the `launchlb` boolean is set to *false*, provide a value here or Terraform will error out
- `lb_internal` **(Optional)**: Is load balancer internal? This is a **boolean** with the default value of **false**

- `lb_HTTPS` **(Optional)**: Is the load balancer listener HTTPS? This is a **boolean** with the default value of **false**
- `target_HTTPS` **(Optional)**: Is the target group HTTPS? This is a **boolean** with the default value of **false**

- `ACN_ARN` **(Semi-Optional):**  In the case that HTTPS is leveraged for listener connections, specify ***ACN ARN*** value 



