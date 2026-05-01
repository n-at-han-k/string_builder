# Web Builders

This guide covers building web-related DSLs with string_builder.

## HTML

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

## CSS Selectors

```ruby
CSS.wrap { div(:container) / ul(:list) / li(:active) / a }
CSS.wrap { body / main("content") / section(:hero) / h1 }
```
```css
div.container > ul.list > li.active > a
body > main#content > section.hero > h1
```

## URLs

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

## Makefile Targets

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

See the [examples directory](https://github.com/n-at-han-k/string_builder/tree/main/examples) for complete working code.
