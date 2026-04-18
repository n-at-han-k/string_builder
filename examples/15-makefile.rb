require_relative "../lib/string_builder"

# ──────────────────────────────────────────────────────────────────
# Makefile Target Builder
#
# First method becomes the target name. Its args become dependencies.
# Subsequent methods become recipe commands.
# ──────────────────────────────────────────────────────────────────

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
