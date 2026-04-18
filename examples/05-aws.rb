require_relative "support/cli_concat"

puts CLI.build(:aws).s3.cp.("s3://my-bucket/data.csv").(".").recursive(true).to_s
# => aws s3 cp s3://my-bucket/data.csv . --recursive

puts CLI.build(:aws).ec2.describe_instances.region("us-east-1").output(:json).to_s
# => aws ec2 describe_instances --region us-east-1 --output json

puts CLI.build(:aws).ecs.update_service
  .cluster("prod")
  .service("web")
  .force_new_deployment(true)
  .to_s
# => aws ecs update_service --cluster prod --service web --force-new-deployment

puts CLI.build(:aws).lambda.invoke
  .function_name("my-function")
  .payload('{"key":"value"}')
  .("output.json")
  .to_s
# => aws lambda invoke --function-name my-function --payload {"key":"value"} output.json

puts CLI.build(:aws).ecr.get_login_password.region("us-east-1").to_s
# => aws ecr get_login_password --region us-east-1

puts CLI.build(:aws).cloudformation.deploy
  .template_file("template.yaml")
  .stack_name("my-stack")
  .capabilities("CAPABILITY_IAM")
  .to_s
# => aws cloudformation deploy --template-file template.yaml --stack-name my-stack --capabilities CAPABILITY_IAM
