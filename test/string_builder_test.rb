# frozen_string_literal: true

require "test_helper"

class StringBuilderTest < Minitest::Test
  def sb(&block)
    StringBuilder.new.wrap(&block)
  end

  def assert_buffer(result, expected)
    assert_equal expected, result.to_a
  end

  def assert_string(result, expected)
    assert_equal expected, result.to_s
  end

  def test_get
    result = sb { get }
    assert_buffer(result, [["get", []]])
    assert_string(result, "get")
  end

  def test_get_deployment
    result = sb { get.deployment }
    assert_buffer(result, [["get", []], ["deployment", []]])
    assert_string(result, "get deployment")
  end


  def test_blockless_chaining
    result = StringBuilder.new.get.deployment
    assert_buffer(result, [["get", []], ["deployment", []]])
    assert_string(result, "get deployment")
  end

  def test_call_with_string_arg
    result = StringBuilder.new.get.("deployment/v1/apps")
    assert_buffer(result, [["get", []], ["deployment/v1/apps", []]])
    assert_string(result, "get deployment/v1/apps")
  end

  def test_call_with_string_arg_then_chain
    result = StringBuilder.new.get.("deployment/v1/apps").all
    assert_buffer(result, [["get", []], ["deployment/v1/apps", []], ["all", []]])
    assert_string(result, "get deployment/v1/apps all")
  end

  def test_call_with_no_args_raises
    assert_raises(ArgumentError) do
      StringBuilder.new.get.()
    end
  end


  def test_method_with_kwargs
    result = StringBuilder.new.get.deployment(replicas: 3)
    assert_buffer(result, [["get", []], ["deployment", [{replicas: 3}]]])
    assert_string(result, "get deployment({replicas: 3})")
  end

  def test_method_with_args_and_kwargs
    result = StringBuilder.new.get.deployment("nginx", replicas: 3)
    assert_buffer(result, [["get", []], ["deployment", ["nginx", {replicas: 3}]]])
    assert_string(result, "get deployment(\"nginx\", {replicas: 3})")
  end

  def test_method_with_multiple_kwargs
    result = StringBuilder.new.get.deployment(replicas: 3, namespace: "default")
    assert_buffer(result, [["get", []], ["deployment", [{replicas: 3, namespace: "default"}]]])
    assert_string(result, "get deployment({replicas: 3, namespace: \"default\"})")
  end

  def test_integer_unit_standalone
    result = 1.app
    assert_instance_of InnerStringBuilder, result
    assert_equal [["1", []], ["app", []]], result.to_a
  end

  # Coercion methods (to_int, to_str, to_ary, etc.) must not be captured
  # by method_missing. If they are, Ruby's implicit type coercion will
  # receive a StringBuilder back instead of raising NoMethodError/TypeError,
  # causing errors like "can't convert InnerStringBuilder to Integer".
  def test_does_not_respond_to_coercion_methods
    builder = StringBuilder.new.foo
    refute builder.respond_to?(:to_int)
    refute builder.respond_to?(:to_str)
    refute builder.respond_to?(:to_ary)
    refute builder.respond_to?(:to_hash)
  end

  def test_coercion_methods_raise_on_string_builder
    builder = StringBuilder.new.foo
    assert_raises(NoMethodError) { builder.to_int }
    assert_raises(NoMethodError) { builder.to_str }
    assert_raises(NoMethodError) { builder.to_ary }
    assert_raises(NoMethodError) { builder.to_hash }
  end

  def test_coercion_methods_raise_on_inner_string_builder
    builder = InnerStringBuilder.new.foo
    assert_raises(NoMethodError) { builder.to_int }
    assert_raises(NoMethodError) { builder.to_str }
    assert_raises(NoMethodError) { builder.to_ary }
    assert_raises(NoMethodError) { builder.to_hash }
  end

  def test_to_s_still_works
    # to_s is explicitly defined, so it must not be blocked
    result = StringBuilder.new.get.deployment
    assert_equal "get deployment", result.to_s
  end

  def test_builder_not_coercible_to_integer_in_array
    builder = StringBuilder.new.foo
    # Simulates what Rack does: [status, headers, body] where status must be Integer
    assert_raises(TypeError) { Integer(builder) }
  end
end
