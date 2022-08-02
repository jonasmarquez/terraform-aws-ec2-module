# AWS EC2 Instance Terraform Module

## HowToUse

1. git clone https://github.com/jonasmarquez/terraform-aws-ec2-module.git
2. cd terraform-aws-ec2-module/example
3. terraform init
4. terraform plan -out=tfplan
5. terraform apply --auto-approve tfplan

---

Or

Copy and paste the following module call code into youre .tf file and change variables:

```
module "ec2-instance" {
  source = "git::https://github.com/jonasmarquez/terraform-aws-ec2-module.git?ref=main"
  #source                 = "../"
  ami                    = "ami-0d51579f02ac97d77"
  instance_type          = "t2.micro"
  subnet_id              = "subnet-046982cad1aab2fe1"
  vpc_security_group_ids = ["sg-0783ce041db3ce42c"]
  key_name               = "<SSH-KEY-PAIR-NAME>"
  tags                   = local.tags
}
```