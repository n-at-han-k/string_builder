require_relative "../lib/string_builder"

# ──────────────────────────────────────────────────────────────────
# Environment Variable Builder
#
# Each method becomes a KEY=value line for .env files.
# Method names are uppercased. Arguments become values.
# ──────────────────────────────────────────────────────────────────

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
