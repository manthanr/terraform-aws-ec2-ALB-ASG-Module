#!/bin/bash
sudo su
yum update -y

#Install and configure httpd
yum install -y httpd 
systemctl start httpd
systemctl enable httpd
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;

#Create Base File
echo "<h1>Hello World From:" > /var/www/html/index.html

#Obtain IMDSv2 Token
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" \
-H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` \
&& curl -H "X-aws-ec2-metadata-token: $TOKEN" \
-v http://169.254.169.254/latest/meta-data/

#Retrieve Private IPv4 address of Server and feed into index.html
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" \
-H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` && \
sudo curl -H "X-aws-ec2-metadata-token: $TOKEN" \
-v http://169.254.169.254/latest/meta-data/local-ipv4 \
>> /var/www/html/index.html


#End Base File
echo "</h1>" >> /var/www/html/index.html
