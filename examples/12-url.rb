require_relative "../lib/string_builder"

# ──────────────────────────────────────────────────────────────────
# URL Builder
#
# Bare methods become path segments. Args become query params.
# Hash args become key=value pairs.
# ──────────────────────────────────────────────────────────────────

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
