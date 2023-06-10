#!/bin/bash


ami_id="ami-092b51d9008adea15"
my_key="my-laptop-key"
az1="us-east-2a"
az2="us-east-2b"
az3="us-east-2c"
name="vpc-group-2"
vpc_name="$name" 
subnetName="$name Subnet"
gatewayName="$name Gateway"
routeTableName="$name Route Table"
securityGroupName="group-2"
vpcCidrBlock="10.0.0.0/16"
subnet_cidr1="10.0.1.0/24"
subnet_cidr2="10.0.2.0/24"
subnet_cidr3="10.0.3.0/24"
instance_name="ec2-group-2"

# Create VPC
vpc_id=$(aws ec2 create-vpc --cidr-block $vpcCidrBlock --output text --query 'Vpc.VpcId')
aws ec2 create-tags --resources $vpc_id --tags Key=Name,Value=$vpc_name


# Create Security Group
security_group_id=$(aws ec2 create-security-group --group-name $securityGroupName --description "Security Group for sg-group-2" --vpc-id "$vpc_id" --output text --query 'GroupId')

# Open inbound ports 22, 80, 443 for the security group
aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 443 --cidr 0.0.0.0/0

# Create Subnets
subnet_1=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block $subnet_cidr1 --availability-zone $az1 --output text --query 'Subnet.SubnetId')
aws ec2 create-tags --resources $subnet_1 --tags Key=Name,Value=public-subnet-1

subnet_2=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block $subnet_cidr2 --availability-zone $az2 --output text --query 'Subnet.SubnetId')
aws ec2 create-tags --resources $subnet_2 --tags Key=Name,Value=public-subnet-2
subnet_3=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block $subnet_cidr3 --availability-zone $az3 --output text --query 'Subnet.SubnetId')
aws ec2 create-tags --resources $subnet_3 --tags Key=Name,Value=public-subnet-3


# Create Internet Gateway
gateway_id=$(aws ec2 create-internet-gateway --output text --query 'InternetGateway.InternetGatewayId')

# Attach Internet Gateway to VPC
aws ec2 attach-internet-gateway --internet-gateway-id $gateway_id --vpc-id $vpc_id

# Create EC2 Instance
instance_id=$(aws ec2 run-instances --image-id $ami_id --instance-type t2.micro --key-name $my_key --security-group-ids $security_group_id --subnet-id $subnet_1 --output text --query 'Instances[0].InstanceId')
aws ec2 create-tags --resources $instance_id --tags Key=Name,Value=$instance_name

# Wait for the EC2 instance to be running
aws ec2 wait instance-running --instance-ids $instance_id


# Create EC2
aws ec2 create-key-pair --key-name EC2KeyPair --query "KeyMaterial" --output text > EC2KeyPair.pem
aws ec2 run-instances --image-id $ami_id --count 1 --instance-type $i_type --key-name EC2KeyPair --security-group-ids $security_group_id --subnet-id $subnet1 --associate-public-ip-address --tag-specificationsResourceType=instance,Tags=[{Key=Name,Value=$instance_name}]
# Install Jenkins on EC2 Instance (assuming Ubuntu-based)
#ssh -i my-key-pair.pem ubuntu@<instance_public_ip> "sudo apt-get update && sudo apt-get install -y jenkins"

