```
terraform init
terraform apply
terraform plan --help
terraform plan
terraform plan -out example.plan
terraform plan -var-file barlow.tfvars -out tf.plan
terraform plan -destroy
terraform plan -destroy -out example.plan

terraform show example.plan
terraform apply example.plan
terraform state list
terraform state show aws_s3_bucket.barlow
terraform show 
terraform show -json | jq .
terraform graph # http://webgraphviz.com/
terraform apply -auto-approve

terraform apply -var "cidr=10.0.0.1/16"

terraform apply -var-file "sensitive.tfvars"

terraform refresh

terraform destroy
terraform destroy -var-file barlow.tfvars
terraform destroy -target aws_instance.nginx

```