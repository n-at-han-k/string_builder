# frozen_string_literal: true

class MethodCallToken
  attr_reader :base
  attr_reader :name
  attr_reader :args

  def initialize(base, name, args)
    @base = base
    @name = name
    @args = args
  end

  def to_s
    "#{base}.#{name}"
  end
end

class StringBuilder
  include Enumerable

  attr_reader :buffer

  DEFAULT_SERIALIZER = proc { |buffer|
    buffer.map { |entry|
      case entry
      when :slash then "/"
      when :dash then "-"
      else
        name, args = entry
        args.empty? ? name : "#{name}(#{args.map(&:inspect).join(', ')})"
      end
    }.join(".")
  }

  def initialize(serializer: DEFAULT_SERIALIZER)
    @buffer = []
    @serializer = serializer
    @operator_pos = nil
  end

  def to_s
    @serializer.call(@buffer)
  end

  def wrap(&block)
    instance_eval(&block)
    self
  end

  def each
    yield @buffer
  end

  def respond_to_missing?(_name, _include_private = false)
    true
  end

  def method_missing(name, *args, &_block)
    tap do
      @buffer << [name.to_s, args]
    end
  end

  def call(token)
    tap do
      @buffer << [token.to_s, []]
    end
  end

  def /(_other)
    tap do
      insert_pos = @operator_pos || (@buffer.length - 1)
      @buffer.insert(insert_pos, :slash)
      @operator_pos = @buffer.length
    end
  end

  def -(other)
    tap do
      case other
      when MethodCallToken
        @buffer << [other.base.to_s, []]
        insert_pos = @operator_pos || (@buffer.length - 1)
        @buffer.insert(insert_pos, :dash)
        @buffer << [other.name.to_s, other.args]
        @operator_pos = @buffer.length
      else
        unless other.is_a?(StringBuilder)
          @buffer << [other.to_s, []]
        end
        insert_pos = @operator_pos || (@buffer.length - 1)
        @buffer.insert(insert_pos, :dash)
        @operator_pos = @buffer.length
      end
    end
  end
end

