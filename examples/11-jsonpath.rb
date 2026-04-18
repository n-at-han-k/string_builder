require_relative "../lib/string_builder"

# ──────────────────────────────────────────────────────────────────
# JSONPath Builder
#
# Method chains become dot-notation paths.
# Integer args become array indices.
# ──────────────────────────────────────────────────────────────────

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
