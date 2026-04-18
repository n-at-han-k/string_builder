# StringBuilder

Ruby method chains &rarr; any string format. 113 lines. Zero dependencies.

```
gem install string_builder
```

---

### Git

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

[See how this works &rarr;](examples/02-git.rb)

---

### Docker

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

[See how this works &rarr;](examples/03-docker.rb)

---

### Terraform

```ruby
Terraform.plan.var("region=us-east-1").var_file("prod.tfvars").out("plan.out")
Terraform.apply.auto_approve(true).("plan.out")
Terraform.destroy.auto_approve(true).target("aws_instance.web")
Terraform.state.mv.("aws_instance.old").("aws_instance.new")
Terraform.import.("aws_instance.web").("i-1234567890abcdef0")
```
```
terraform plan --var region=us-east-1 --var-file prod.tfvars --out plan.out
terraform apply --auto-approve plan.out
terraform destroy --auto-approve --target aws_instance.web
terraform state mv aws_instance.old aws_instance.new
terraform import aws_instance.web i-1234567890abcdef0
```

[See how this works &rarr;](examples/04-terraform.rb)

---

### AWS

```ruby
AWS.s3.cp.("s3://my-bucket/data.csv").(".").recursive(true)
AWS.lambda.invoke.function_name("my-function").payload('{"key":"value"}').("output.json")
AWS.cloudformation.deploy.template_file("template.yaml").stack_name("my-stack")
```
```
aws s3 cp s3://my-bucket/data.csv . --recursive
aws lambda invoke --function-name my-function --payload {"key":"value"} output.json
aws cloudformation deploy --template-file template.yaml --stack-name my-stack
```

[See how this works &rarr;](examples/05-aws.rb)

---

### SQL

```ruby
SQL.query { columns(:name, :email).from("users").where(active: true) }
SQL.query { delete.from("sessions").where(expired: true) }
SQL.query { insert.into("users").values("alice", "alice@example.com", 28) }
SQL.query {
  columns(:id, :name)
    .from("products")
    .where(category: "electronics")
    .order_by(:price)
    .limit(10)
}
```
```sql
SELECT name, email FROM 'users' WHERE active = TRUE
DELETE FROM 'sessions' WHERE expired = TRUE
INSERT INTO 'users' VALUES 'alice', 'alice@example.com', 28
SELECT id, name FROM 'products' WHERE category = 'electronics' ORDER BY price LIMIT 10
```

[See how this works &rarr;](examples/09-sql.rb)

---

### HTML

```ruby
HTML.tag.h1("Hello, World!")
HTML.tag.a("Click here", href: "/about", class: "link")
HTML.build { div(class: "container") / h1("Welcome back.") }
HTML.build { nav(class: "sidebar") / ul / li("Dashboard") }
```
```html
<h1>Hello, World!</h1>
<a href="/about" class="link">Click here</a>
<div class="container">
  <h1>Welcome back.</h1>
</div>
<nav class="sidebar">
  <ul>
    <li>Dashboard</li>
  </ul>
</nav>
```

[See how this works &rarr;](examples/10-html.rb)

---

### Same chain, different output

One buffer. Swap the handler.

```ruby
sb = StringBuilder.new.get.users.page(1).limit(25)
```

| Handler  | Output |
|----------|--------|
| Default  | `get users page(1) limit(25)` |
| URL      | `/get/users?page=1&limit=25` |
| JSONPath | `$.get.users.page[1].limit[25]` |

[See how this works &rarr;](examples/16-multi-render.rb)

---

### .env files

```ruby
Env.database_url("postgres://localhost:5432/myapp")
   .redis_url("redis://localhost:6379")
   .secret_key_base("a1b2c3d4e5f6")
   .rails_env("production")
   .port(3000)
```
```
DATABASE_URL=postgres://localhost:5432/myapp
REDIS_URL=redis://localhost:6379
SECRET_KEY_BASE=a1b2c3d4e5f6
RAILS_ENV=production
PORT=3000
```

[See how this works &rarr;](examples/14-env.rb)

---

### CSS selectors

```ruby
CSS.wrap { div(:container) / ul(:list) / li(:active) / a }
CSS.wrap { body / main("content") / section(:hero) / h1 }
```
```css
div.container > ul.list > li.active > a
body > main#content > section.hero > h1
```

[See how this works &rarr;](examples/13-css.rb)

---

### JSONPath

```ruby
JP.data.users(0).name
JP.store.book(2).author
JP.response.items(0).metadata.labels
```
```
$.data.users[0].name
$.store.book[2].author
$.response.items[0].metadata.labels
```

[See how this works &rarr;](examples/11-jsonpath.rb)

---

### URLs

```ruby
URL.api.v2.users
URL.api.v1.search.page(1).limit(25)
URL.api.v3.repos.("octocat/hello-world").commits.per_page(10)
```
```
/api/v2/users
/api/v1/search?page=1&limit=25
/api/v3/repos/octocat/hello-world/commits?per_page=10
```

[See how this works &rarr;](examples/12-url.rb)

---

### Makefile targets

```ruby
Make.build(:clean, :deps).go.build("./...")
Make.test.go.test("./...", "-v", "-race")
```
```makefile
build: clean deps
	go build ./...

test:
	go test ./... -v -race
```

[See how this works &rarr;](examples/15-makefile.rb)

---

---

### Built with StringBuilder

#### [kube_ctl](https://github.com/general-intelligence-systems/kube_ctl) -- kubectl & helm as Ruby DSLs

```ruby
Kube.ctl { create.namespace.my-app }
Kube.ctl { apply.f './k8s/deployment.yaml' }
Kube.ctl { get.pods.o(:wide) }
Kube.ctl { logs.f(true).deployment/web.c('my-app') }
Kube.ctl { scale.deployment/web.replicas(5) }
Kube.ctl { set.image.deployment/web.('my-app=registry.example.com/my-app:v2') }
Kube.ctl { rollout.undo.deployment/web.to_revision(3) }
Kube.ctl { exec.i(true).t(true).web.c('my-app').('-- /bin/sh') }
```
```
kubectl create namespace my-app
kubectl apply -f ./k8s/deployment.yaml
kubectl get pods -o wide
kubectl logs -f deployment/web -c my-app
kubectl scale deployment/web --replicas=5
kubectl set image deployment/web my-app=registry.example.com/my-app:v2
kubectl rollout undo deployment/web --to-revision=3
kubectl exec -i -t web -c my-app -- /bin/sh
```

```ruby
Kube.helm { repo.add.("bitnami").("https://charts.bitnami.com/bitnami") }
Kube.helm {
  install.my_nginx.("bitnami/nginx")
    .f("values.yaml")
    .set("image.tag=1.25.0")
    .namespace("web")
    .create_namespace(true)
    .wait(true)
    .timeout("5m0s")
}
Kube.helm {
  upgrade.install(true).my_nginx.("bitnami/nginx")
    .reuse_values(true)
    .set("image.tag=1.26.0")
    .namespace("web")
}
```
```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-nginx bitnami/nginx -f values.yaml --set image.tag=1.25.0 --namespace=web --create-namespace --wait --timeout=5m0s
helm upgrade --install my-nginx bitnami/nginx --reuse-values --set image.tag=1.26.0 --namespace=web
```

A full 31-step deployment walkthrough and 10-step helm workflow. `gem install kube_kubectl`

[kubectl examples &rarr;](https://github.com/general-intelligence-systems/kube_ctl/blob/main/examples/kubectl_deploy_app.rb) &#183; [helm examples &rarr;](https://github.com/general-intelligence-systems/kube_ctl/blob/main/examples/helm_install_chart.rb)

---

The library is 113 lines. Every example above is a different concat handler -- a single `.call(buffer)` method that decides how tokens become strings. The chain is data. The handler is interpretation.

[Start with the basics &rarr;](examples/01-basic.rb)
