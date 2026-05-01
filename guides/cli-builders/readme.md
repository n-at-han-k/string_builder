# CLI Builders

This guide covers building command-line tool DSLs with string_builder.

## Git

```ruby
Git.commit.m("fix: null pointer in parser")
Git.push.origin.main.force(true)
Git.log.oneline(true).graph(true).n(20)
Git.rebase.i(true).("HEAD~5")
```
```
git commit -m fix: null pointer in parser
git push origin main --force
git log --oneline --graph -n 20
git rebase -i HEAD~5
```

## Docker

```ruby
Docker.run.d(true).name("web").p("8080:80").("nginx:latest")
Docker.build.t("myapp:latest").no_cache(true).(".")
Docker.compose.up.d(true).build(true).remove_orphans(true)
```
```
docker run -d --name web -p 8080:80 nginx:latest
docker build -t myapp:latest --no-cache .
docker compose up -d --build --remove-orphans
```

## Terraform

```ruby
Terraform.plan.var("region=us-east-1").var_file("prod.tfvars").out("plan.out")
Terraform.apply.auto_approve(true).("plan.out")
Terraform.destroy.auto_approve(true).target("aws_instance.web")
```
```
terraform plan --var region=us-east-1 --var-file prod.tfvars --out plan.out
terraform apply --auto-approve plan.out
terraform destroy --auto-approve --target aws_instance.web
```

## AWS

```ruby
AWS.s3.cp.("s3://my-bucket/data.csv").(".").recursive(true)
AWS.lambda.invoke.function_name("my-function").payload('{"key":"value"}').("output.json")
```
```
aws s3 cp s3://my-bucket/data.csv . --recursive
aws lambda invoke --function-name my-function --payload {"key":"value"} output.json
```

See the [examples directory](https://github.com/n-at-han-k/string_builder/tree/main/examples) for complete working code.
