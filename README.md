# H1 Terraform Example for AWS

Launching a ec2 instance and, up a docker compose application. Automation.

#

**Prerequisite**
1. AWS account with right to create resources.
2. AWS CLI
3. Code editor ( VS Code recommended )
---
**Steps**

- main.tf is the default resources file in Terra Form. Name your file main.tf
- Go to directory, and open a terminal in the folder with your tf file.
- Get AWS credentials and give it to the terminal. 
- run
```bash
terraform init
```
- This will create get all the resources data for the provider, we give in the
```terraform
provider "aws" {
  region     = "us-west-2"
}
```
In this case, it is aws in us west 2 region. Change region as your need.

- Use terraform validate to check your code.
```bash
terraform validate
```
- Use terraform plan to check for the resources which will get created.  
```bash
terraform plan
```
- IMPORTANT; The instance we creating here is t3.medium. It is not a free tier. We need more resources for the provided application so, here a t3.medium is used. And, the AMI can be changed over time. Grab the latest one or any ubuntu one but 22.02 is recommended. [AMI list](https://cloud-images.ubuntu.com/locator/ec2/) 
- After that, use apply and give permission with yes key word.
```bash
terraform apply
```

Wait till things are created and use the public ip to check your application.