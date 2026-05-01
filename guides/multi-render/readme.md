# Multi-Render

This guide covers rendering the same method chain in different formats by swapping handlers.

## One Buffer, Multiple Outputs

```ruby
sb = StringBuilder.new.get.users.page(1).limit(25)
```

| Handler  | Output |
|----------|--------|
| Default  | `get users page(1) limit(25)` |
| URL      | `/get/users?page=1&limit=25` |
| JSONPath | `$.get.users.page[1].limit[25]` |

The chain is data. The handler is interpretation. Swap the handler, get a different string format from the same method chain.

See the [multi-render example](https://github.com/n-at-han-k/string_builder/blob/main/examples/16-multi-render.rb) for the complete working code.
