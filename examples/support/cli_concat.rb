require_relative "../../lib/string_builder"

# Shared CLI concat handler.
#
# Convention:
#   - Single-char methods become short flags:     .f("file") -> -f file
#   - Multi-char methods become long flags:        .output("json") -> --output json
#   - true args become boolean flags:              .force(true) -> --force
#   - Bare methods become subcommands/args:        .get.pods -> get pods
#   - Underscores become hyphens in flags:         .dry_run(true) -> --dry-run
#   - .call() injects raw tokens:                  .("literal") -> literal
#   - Hash args become key=value:                  .l(app: "web") -> -l app=web
#   - Symbols stay unquoted:                       .o(:json) -> -o json

module CLI
  class Concat
    def self.call(buffer) = new(buffer).render

    def initialize(buffer) = @buffer = buffer

    def render
      @buffer.filter_map { |entry|
        case entry
        when :slash then "/"
        when :dash then "-"
        else
          name, args = entry
          format_token(name, args)
        end
      }.join(" ")
    end

    private

    def format_token(name, args)
      return name if args.empty?

      if args.length == 1 && args.first.is_a?(Hash)
        flag = flag_for(name)
        kv = args.first.map { |k, v| "#{k}=#{v}" }.join(",")
        return "#{flag} #{kv}"
      end

      return flag_for(name) if args == [true]
      return nil if args == [false]

      flag = flag_for(name)
      vals = args.map { |a| a.is_a?(Symbol) ? a.to_s : a.to_s }
      "#{flag} #{vals.join(',')}"
    end

    def flag_for(name)
      dashed = name.tr("_", "-")
      dashed.length == 1 ? "-#{dashed}" : "--#{dashed}"
    end
  end

  def self.build(tool)
    StringBuilder.new { |buf| "#{tool} #{Concat.call(buf)}" }
  end
end
