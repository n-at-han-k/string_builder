require_relative "support/cli_concat"

puts CLI.build(:terraform).init.backend_config("key=prod/terraform.tfstate").to_s
# => terraform init --backend-config key=prod/terraform.tfstate

puts CLI.build(:terraform).plan.var("region=us-east-1").var_file("prod.tfvars").out("plan.out").to_s
# => terraform plan --var region=us-east-1 --var-file prod.tfvars --out plan.out

puts CLI.build(:terraform).apply.auto_approve(true).("plan.out").to_s
# => terraform apply --auto-approve plan.out

puts CLI.build(:terraform).destroy.auto_approve(true).target("aws_instance.web").to_s
# => terraform destroy --auto-approve --target aws_instance.web

puts CLI.build(:terraform).workspace.new.("staging").to_s
# => terraform workspace new staging

puts CLI.build(:terraform).state.mv.("aws_instance.old").("aws_instance.new").to_s
# => terraform state mv aws_instance.old aws_instance.new

puts CLI.build(:terraform).import.("aws_instance.web").("i-1234567890abcdef0").to_s
# => terraform import aws_instance.web i-1234567890abcdef0

puts CLI.build(:terraform).output.json(true).to_s
# => terraform output --json
