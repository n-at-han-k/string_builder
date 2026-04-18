require_relative "../lib/string_builder"

# ──────────────────────────────────────────────────────────────────
# One buffer, multiple renderings.
#
# The same method chain rendered through different concat handlers
# produces completely different output. The chain is data.
# The handler is interpretation.
# ──────────────────────────────────────────────────────────────────

module JSONPath
  def self.call(buffer)
    "$." + buffer.map { |entry|
      case entry
      when Symbol then entry.to_s
      else
        name, args = entry
        if args.empty?
          name
        elsif args.first.is_a?(Integer)
          "#{name}[#{args.first}]"
        else
          name
        end
      end
    }.join(".")
  end
end

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

# ──────────────────────────────────────────────────────────────────

sb = StringBuilder.new.get.users.page(1).limit(25)

puts "Default:  #{sb.to_s}"
# => Default:  get users page(1) limit(25)

puts "URL:      #{sb.to_s { |buf| URLBuilder.call(buf) }}"
# => URL:      /get/users?page=1&limit=25

sb.concat_handler = JSONPath
puts "JSONPath: #{sb.to_s}"
# => JSONPath: $.get.users.page[1].limit[25]
