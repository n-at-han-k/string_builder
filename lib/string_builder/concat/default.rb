class StringBuilder
  module Concat
    class Default
      attr_reader :buffer

      def self.call(buffer) = new(buffer).concat
      def initialize(buffer) = @buffer = buffer

      def concat
        buffer.map { |entry|
          case entry
          when :slash then "/"
          when :dash then "-"
          else
            name, args, kwargs = entry
            all_args = args.map(&:inspect)
            all_args.concat(kwargs.map { |k, v| "#{k}: #{v.inspect}" }) if kwargs&.any?
            all_args.empty? ? name : "#{name}(#{all_args.join(', ')})"
          end
        }.join(" ")
      end
    end
  end
end
