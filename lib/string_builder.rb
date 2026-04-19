# frozen_string_literal: true

require_relative 'string_builder/version'
require_relative 'string_builder/concat/default'

class StringBuilder
  include Enumerable

  class Buffer < Array
    # Allows us to pass StringBuilder objects into the buffer
    # and have them show up as arrays. Once they're in the buffer
    # we don't want nested buffers anyway.
    def <<(value)
      value = value.to_a unless value.is_a?(Symbol)
      super
    end
  end

  attr_accessor :concat_handler

  def initialize(&custom_concat)
    @buffer = Buffer.new
    @concat_handler = custom_concat || Concat::Default
  end

  def wrap(&block)
    tap do
      ScopedStringBuilder.new.instance_eval(&block).each do |token|
        @buffer << token
      end
    end
  end

  def to_s(&block)
    if block_given?
      block.call(self)
    else
      @concat_handler.call(self)
    end
  end

  def each(&block)
    @buffer.each(&block)
  end

  def call(token)
    tap do
      @buffer << [token.to_s, []]
    end
  end

  private

  def respond_to_missing?(*) = true

  def method_missing(name, *args, **kwargs, &_block)
    tap do
      @buffer << if kwargs.empty?
                   [name.to_s, args]
                 else
                   [name.to_s, [*args, kwargs]]
                 end
    end
  end
end

class ScopedStringBuilder < StringBuilder
  private

  def method_missing(name, *args, **kwargs, &_block)
    InnerStringBuilder.new.send(name, *args, **kwargs)
  end
end

class InnerStringBuilder < StringBuilder
  OPERATOR_MAP = { "/": :slash, "-": :dash }

  def initialize
    @buffer = Buffer.new
  end

  OPERATOR_MAP.keys.each do |operator|
    define_method(operator) do |other|
      tap do
        @buffer << OPERATOR_MAP[operator]
        other.each { |token| @buffer << token }
      end
    end
  end
end

# Ruby evaluates `3.px` as Integer#px — a method call on the literal 3.
# Without this patch, that raises NoMethodError because Integer has no `px`.
#
# Inside a ScopedStringBuilder block, expressions like `a.b / 3.px` need the
# right-hand operand `3.px` to produce an InnerStringBuilder so the `/`
# operator can cleanly append the separator symbol followed by the operand's
# tokens. The problem is that Ruby resolves `3.px` *before* `/` is called,
# and it resolves it on Integer, not on the ScopedStringBuilder.
#
# The monkey patch bridges this gap: any unknown method on an Integer creates
# a new InnerStringBuilder, records the integer as the first token via `call`,
# then forwards the method (e.g. `px`) so it chains naturally. The result is
# a standalone builder that the operator receives as a distinct `other` object
# — no different from how any other right-hand operand works.
class ::Integer
  def method_missing(*)
    InnerStringBuilder.new.call(to_s).send(*)
  end
end
