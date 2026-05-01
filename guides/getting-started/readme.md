# Getting Started

This guide walks you through installing string_builder and building your first DSL.

## Install

```
gem install string_builder
```

## Basic Usage

StringBuilder captures Ruby method chains into a buffer and serializes them to strings. 113 lines. Zero dependencies.

```ruby
sb = StringBuilder.new.get.users.page(1).limit(25)
sb.to_s  # => "get users page(1) limit(25)"
```

## How It Works

The library is 113 lines. Every example in the documentation is a different concat handler -- a single `.call(buffer)` method that decides how tokens become strings. The chain is data. The handler is interpretation.

See the [examples directory](https://github.com/n-at-han-k/string_builder/tree/main/examples) for complete working examples.
