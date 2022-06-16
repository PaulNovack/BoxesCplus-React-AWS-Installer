# BoxesCplus-React-AWS-Installer

### Requires configured AWS CLI and Terraform installed

### This is an example only in a real world installer you would NEVER put the private public key in code that is checked into github it would be in a terraform var file.

This will install and configure 2 ec2 instances

1 Ec2 Instance running mysql configured with user and password and port 33060 open (RDS on Amazon does not currently support mySQL devX connections)

2 Ec2 Instance running C++ web app and the React Web Application.

Installer gets latest ubuntu 20.04 image in AWS 
Installs build essentials for C++ and Node and all libraries required to compile both c++ application and React Application

To run;  terraform apply

To remove all aws instances: terraform destroy

### After running the installer look at the IP address output by installer you should he able to access:
<pre>
  - ec2_web_ip      = [
      - "IP Address",
    ] 
    
    http://IP Address/
    
    </pre>

There is a bug in the current react code you will have to log in twice till fixed.

