# StringBuilder

Ruby method chains &rarr; any string format. 113 lines. Zero dependencies.

```
gem install string_builder
```

---

### CLI commands

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

```ruby
Terraform.plan.var("region=us-east-1").var_file("prod.tfvars").out("plan.out")
Terraform.apply.auto_approve(true).("plan.out")
```
```
terraform plan --var region=us-east-1 --var-file prod.tfvars --out plan.out
terraform apply --auto-approve plan.out
```

[See how this works &rarr;](examples/cli_builder.rb)

---

### SQL queries

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

[See how this works &rarr;](examples/query_builder.rb)

---

### HTML markup

```ruby
HTML.tag.h1("Hello, World!")
HTML.tag.a("Click here", href: "/about", class: "link")
HTML.tag.img(src: "/logo.png", alt: "Logo")
HTML.build { div(class: "container") / h1("Welcome back.") }
HTML.build { nav(class: "sidebar") / ul / li("Dashboard") }
```
```html
<h1>Hello, World!</h1>
<a href="/about" class="link">Click here</a>
<img src="/logo.png" alt="Logo">
<div class="container">
  <h1>Welcome back.</h1>
</div>
<nav class="sidebar">
  <ul>
    <li>Dashboard</li>
  </ul>
</nav>
```

[See how this works &rarr;](examples/html_builder.rb)

---

### Same chain, different output

One buffer. Swap the concat handler. Get a completely different string.

```ruby
sb = StringBuilder.new.get.users.page(1).limit(25)
```

| Handler  | Output |
|----------|--------|
| Default  | `get users page(1) limit(25)` |
| URL      | `/get/users?page=1&limit=25` |
| JSONPath | `$.get.users.page[1].limit[25]` |

```ruby
sb.data.users(0).name                    # $.data.users[0].name
sb.api.v1.search.page(1).limit(25)       # /api/v1/search?page=1&limit=25
sb.wrap { div(:card) / ul(:list) / li }  # div.card > ul.list > li
```

[See how this works &rarr;](examples/custom_concat.rb)

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

[See how this works &rarr;](examples/custom_concat.rb)

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

[See how this works &rarr;](examples/custom_concat.rb)

---

The library is 113 lines. Every example above is a different concat handler -- a single `.call(buffer)` method that decides how tokens become strings. The chain is data. The handler is interpretation.

[Start with the basics &rarr;](examples/basic.rb)
