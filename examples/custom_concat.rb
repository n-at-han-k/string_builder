require_relative "../lib/string_builder"

# ──────────────────────────────────────────────────────────────────
# Custom Concat Handlers
#
# The default concat handler joins tokens with spaces.
# But the concat handler is just a callable — swap it out
# and the same method chain renders to completely different output.
#
# This is where StringBuilder stops being a string builder
# and becomes a general-purpose method chain recorder.
# ──────────────────────────────────────────────────────────────────

# === 1. JSON Path Builder ===
# Method chains become dot-notation paths.

module JSONPath
  def self.call(buffer)
    "$." + buffer.map { |entry|
      case entry
      when :slash then "/"
      when :dash then "-"
      else
        name, args = entry
        if args.empty?
          name
        elsif args.first.is_a?(Integer)
          "#{name}[#{args.first}]"
        else
          "#{name}[?(@.#{args.first})]"
        end
      end
    }.join(".")
  end
end

sb = StringBuilder.new { |buf| JSONPath.call(buf) }
puts sb.wrap { data.users(0).name }.to_s
# => $.data.users[0].name

sb = StringBuilder.new { |buf| JSONPath.call(buf) }
puts sb.wrap { store.book(2).author }.to_s
# => $.store.book[2].author

sb = StringBuilder.new { |buf| JSONPath.call(buf) }
puts sb.wrap { response.items(0).metadata.labels }.to_s
# => $.response.items[0].metadata.labels

puts ""

# === 2. URL Builder ===
# Method chains become URL path segments. Args become query params.

module URLBuilder
  def self.call(buffer)
    path_parts = []
    query_params = []

    buffer.each do |entry|
      next if entry.is_a?(Symbol)
      name, args = entry
      if args.empty?
        path_parts << name
      else
        args.each do |arg|
          case arg
          when Hash then arg.each { |k, v| query_params << "#{k}=#{v}" }
          else query_params << "#{name}=#{arg}"
          end
        end
      end
    end

    url = "/" + path_parts.join("/")
    url += "?" + query_params.join("&") unless query_params.empty?
    url
  end
end

# Blockless chaining — no collisions to worry about
sb = StringBuilder.new { |buf| URLBuilder.call(buf) }
puts sb.api.v2.users.to_s
# => /api/v2/users

sb = StringBuilder.new { |buf| URLBuilder.call(buf) }
puts sb.api.v1.search.page(1).limit(25).to_s
# => /api/v1/search?page=1&limit=25

sb = StringBuilder.new { |buf| URLBuilder.call(buf) }
puts sb.api.v1.users(status: "active", role: "admin").to_s
# => /api/v1/users?status=active&role=admin

sb = StringBuilder.new { |buf| URLBuilder.call(buf) }
puts sb.api.v3.repos.("octocat/hello-world").commits.per_page(10).to_s
# => /api/v3/repos/octocat/hello-world/commits?per_page=10

puts ""

# === 3. CSS Selector Builder ===
# Blockless chaining builds CSS selectors.

module CSSSelector
  def self.call(buffer)
    parts = []
    pending_dash = false
    buffer.each do |entry|
      case entry
      when :slash then parts << " > "
      when :dash
        pending_dash = true
      else
        name, args = entry
        if pending_dash && parts.any?
          # Merge with previous: "nav" + dash + "list" -> "nav-list"
          prev = parts.pop
          name = "#{prev}#{name}"
          pending_dash = false
        end
        token = name
        args.each do |arg|
          case arg
          when Symbol then token += ".#{arg}"
          when String then token += "##{arg}"
          when Hash
            arg.each { |k, v| token += "[#{k}=\"#{v}\"]" }
          end
        end
        parts << token
      end
    end
    parts.join("")
  end
end

sb = StringBuilder.new { |buf| CSSSelector.call(buf) }
puts sb.wrap { div(:container) / ul(:list) / li(:active) / a }.to_s
# => div.container > ul.list > li.active > a

sb = StringBuilder.new { |buf| CSSSelector.call(buf) }
puts sb.wrap { body / main("content") / section(:hero) / h1 }.to_s
# => body > main#content > section.hero > h1

# Blockless for attribute selectors (avoids input collision)
sb = StringBuilder.new { |buf| CSSSelector.call(buf) }
puts sb.wrap { div(type: "text", name: "email") }.to_s
# => div[type="text"][name="email"]

puts ""

# === 4. Environment Variable Builder ===
# Each method becomes a KEY=value line for .env files.

module EnvBuilder
  def self.call(buffer)
    buffer.filter_map { |entry|
      next if entry.is_a?(Symbol)
      name, args = entry
      key = name.upcase
      next key if args.empty?
      "#{key}=#{args.first}"
    }.join("\n")
  end
end

sb = StringBuilder.new { |buf| EnvBuilder.call(buf) }
puts sb.database_url("postgres://localhost:5432/myapp")
       .redis_url("redis://localhost:6379")
       .secret_key_base("a1b2c3d4e5f6")
       .rails_env("production")
       .port(3000)
       .to_s
# => DATABASE_URL=postgres://localhost:5432/myapp
#    REDIS_URL=redis://localhost:6379
#    SECRET_KEY_BASE=a1b2c3d4e5f6
#    RAILS_ENV=production
#    PORT=3000

puts ""

# === 5. Makefile Target Builder ===
# Method chains define make targets with dependencies and recipes.

module MakeTarget
  def self.call(buffer)
    entries = buffer.reject { |e| e.is_a?(Symbol) }
    return "" if entries.empty?

    target_name, target_args = entries.first
    deps = target_args.map(&:to_s).join(" ")
    recipes = entries[1..].map { |name, args|
      cmd = ([name] + args.map(&:to_s)).join(" ")
      "\t#{cmd}"
    }

    header = deps.empty? ? "#{target_name}:" : "#{target_name}: #{deps}"
    ([header] + recipes).join("\n")
  end
end

sb = StringBuilder.new { |buf| MakeTarget.call(buf) }
puts sb.build(:clean, :deps).go.build("./...").to_s
# => build: clean deps
#    	go build ./...

puts ""

sb = StringBuilder.new { |buf| MakeTarget.call(buf) }
puts sb.test.go.test("./...", "-v", "-race").to_s
# => test:
#    	go test ./... -v -race

puts ""

# === 6. One buffer, multiple renderings ===
# The same chain can be rendered differently depending on context.

sb = StringBuilder.new.get.users.page(1).limit(25)

# Default rendering (space-separated with args):
puts "Default:  #{sb.to_s}"
# => Default:  get users page(1) limit(25)

# Inline override with a block — render as a URL:
puts "URL:      #{sb.to_s { |buf| URLBuilder.call(buf) }}"
# => URL:      /get/users?page=1&limit=25

# Swap the handler entirely:
sb.concat_handler = JSONPath
puts "JSONPath: #{sb.to_s}"
# => JSONPath: $.get.users.page.limit

puts ""

# ──────────────────────────────────────────────────────────────────
# StringBuilder records method chains. Concat handlers interpret them.
# Same data, infinite representations.
# ──────────────────────────────────────────────────────────────────
