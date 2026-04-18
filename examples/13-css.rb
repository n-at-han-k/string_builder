require_relative "../lib/string_builder"

# ──────────────────────────────────────────────────────────────────
# CSS Selector Builder
#
# The slash operator creates descendant combinators.
# Symbols become class names. Strings become IDs.
# Hash args become attribute selectors.
# ──────────────────────────────────────────────────────────────────

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

sb = StringBuilder.new { |buf| CSSSelector.call(buf) }
puts sb.wrap { div(type: "text", name: "email") }.to_s
# => div[type="text"][name="email"]
