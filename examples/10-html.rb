require_relative "../lib/string_builder"

# ──────────────────────────────────────────────────────────────────
# HTML Builder
#
# The slash operator creates nesting. Method args become attributes
# or text content. Pure Ruby method chains become markup.
# ──────────────────────────────────────────────────────────────────

module HTML
  VOID_ELEMENTS = %w[area base br col embed hr img input link meta param source track wbr].freeze

  class Concat
    def self.call(buffer) = new(buffer).render

    def initialize(buffer) = @buffer = buffer

    def render
      tokens = @buffer.to_a
      build_html(tokens)
    end

    private

    def build_html(tokens)
      result = []
      raw_entries = []
      i = 0

      while i < tokens.length
        token = tokens[i]

        if token == :slash
          if raw_entries.any?
            result.pop
            outer_entry = raw_entries.pop
            inner_tokens = tokens[(i + 1)..]
            inner_html = build_html(inner_tokens)
            result << wrap_tag(outer_entry, inner_html)
            break
          end
        elsif token == :dash
          i += 1
          next
        else
          result << format_element(token)
          raw_entries << token
        end

        i += 1
      end

      result.join("\n")
    end

    def format_element(entry)
      name, args = entry
      text = nil
      attrs = {}

      args.each do |arg|
        case arg
        when String then text = arg
        when Hash then attrs.merge!(arg)
        when Symbol then attrs[:class] = [attrs[:class], arg.to_s].compact.join(" ")
        end
      end

      if VOID_ELEMENTS.include?(name)
        "<#{name}#{render_attrs(attrs)}>"
      elsif text
        "<#{name}#{render_attrs(attrs)}>#{text}</#{name}>"
      elsif attrs.any?
        "<#{name}#{render_attrs(attrs)}>"
      else
        "<#{name}>"
      end
    end

    def wrap_tag(entry, inner)
      name, args = entry
      attrs = {}
      args.each do |arg|
        case arg
        when Hash then attrs.merge!(arg)
        when Symbol then attrs[:class] = [attrs[:class], arg.to_s].compact.join(" ")
        end
      end
      "<#{name}#{render_attrs(attrs)}>\n  #{inner.gsub("\n", "\n  ")}\n</#{name}>"
    end

    def render_attrs(attrs)
      return "" if attrs.empty?
      " " + attrs.map { |k, v|
        v == true ? k.to_s.tr("_", "-") : "#{k.to_s.tr('_', '-')}=\"#{v}\""
      }.join(" ")
    end
  end

  def self.tag
    StringBuilder.new { |buf| Concat.call(buf) }
  end

  def self.build(&block)
    StringBuilder.new { |buf| Concat.call(buf) }.wrap(&block).to_s
  end
end

# ──────────────────────────────────────────────────────────────────

puts HTML.tag.h1("Hello, World!").to_s
# => <h1>Hello, World!</h1>

puts HTML.tag.span("A paragraph of text.", class: "intro").to_s
# => <span class="intro">A paragraph of text.</span>

puts HTML.tag.img(src: "/logo.png", alt: "Logo").to_s
# => <img src="/logo.png" alt="Logo">

puts HTML.tag.a("Click here", href: "/about", class: "link").to_s
# => <a href="/about" class="link">Click here</a>

puts ""

puts HTML.build { div(class: "container") / h1("Welcome back.") }
# => <div class="container">
#      <h1>Welcome back.</h1>
#    </div>

puts ""

puts HTML.build { nav(class: "sidebar") / ul / li("Dashboard") }
# => <nav class="sidebar">
#      <ul>
#        <li>Dashboard</li>
#      </ul>
#    </nav>

puts ""

puts HTML.build { article(:card) / h2("Card Title") }
# => <article class="card">
#      <h2>Card Title</h2>
#    </article>

puts ""

puts HTML.build { header(class: "top") / h1("My Site") }
# => <header class="top">
#      <h1>My Site</h1>
#    </header>
