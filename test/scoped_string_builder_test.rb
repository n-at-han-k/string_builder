# frozen_string_literal: true

require "test_helper"

class ScopedStringBuilderTest < Minitest::Test
  def sb(&block)
    StringBuilder.new.wrap(&block)
  end

  def assert_buffer(result, expected)
    assert_equal expected, result.to_a
  end

  def assert_string(result, expected)
    assert_equal expected, result.to_s
  end

  def test_method_with_kwargs
    result = sb { get.deployment(replicas: 3) }
    assert_buffer(result, [["get", []], ["deployment", [{replicas: 3}]]])
    assert_string(result, "get deployment({replicas: 3})")
  end

  def test_method_with_args_and_kwargs
    result = sb { get.deployment("nginx", replicas: 3) }
    assert_buffer(result, [["get", []], ["deployment", ["nginx", {replicas: 3}]]])
    assert_string(result, "get deployment(\"nginx\", {replicas: 3})")
  end

  {
    slash: { symbol: :slash, separator: " / ", op: :/ },
    dash:  { symbol: :dash,  separator: " - ", op: :- }
  }.each do |name, cfg|
    symbol = cfg[:symbol]
    sep = cfg[:separator]
    op = cfg[:op]

    # a.b<op>c
    define_method(:"test_#{name}_single_operator") do
      result = sb { a.b.send(op, c) }
      assert_buffer(result, [["a", []], ["b", []], symbol, ["c", []]])
      assert_string(result, "a b#{sep}c")
    end

    # a.b<op>c<op>d
    define_method(:"test_#{name}_chained_operators") do
      result = sb { a.b.send(op, c).send(op, d) }
      assert_buffer(result, [["a", []], ["b", []], symbol, ["c", []], symbol, ["d", []]])
      assert_string(result, "a b#{sep}c#{sep}d")
    end

    # a.b.c<op>d
    define_method(:"test_#{name}_after_method_chain") do
      result = sb { a.b.c.send(op, d) }
      assert_buffer(result, [["a", []], ["b", []], ["c", []], symbol, ["d", []]])
      assert_string(result, "a b c#{sep}d")
    end

    # a.b<op>c.d
    define_method(:"test_#{name}_with_trailing_chain") do
      result = sb { a.b.send(op, c).d }
      assert_buffer(result, [["a", []], ["b", []], symbol, ["c", []], ["d", []]])
      assert_string(result, "a b#{sep}c d")
    end

    # a.b <op> 3.px
    define_method(:"test_#{name}_with_integer_unit") do
      result = sb { a.b.send(op, 3.px) }
      assert_buffer(result, [["a", []], ["b", []], symbol, ["3", []], ["px", []]])
      assert_string(result, "a b#{sep}3 px")
    end

    # a.b<op>c.d("arg")
    define_method(:"test_#{name}_with_trailing_chain_and_args") do
      result = sb { a.b.send(op, c).d("arg") }
      assert_buffer(result, [["a", []], ["b", []], symbol, ["c", []], ["d", ["arg"]]])
      assert_string(result, "a b#{sep}c d(\"arg\")")
    end

    # a.b<op>c.d<op>e — operator after trailing chain
    define_method(:"test_#{name}_operator_after_trailing_chain") do
      result = sb { a.b.send(op, c).d.send(op, e) }
      assert_buffer(result, [["a", []], ["b", []], symbol, ["c", []], ["d", []], symbol, ["e", []]])
      assert_string(result, "a b#{sep}c d#{sep}e")
    end
  end
end
