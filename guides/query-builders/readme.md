# Query Builders

This guide covers building query and data-access DSLs with string_builder.

## SQL

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

## JSONPath

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

## .env Files

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

See the [examples directory](https://github.com/n-at-han-k/string_builder/tree/main/examples) for complete working code.
