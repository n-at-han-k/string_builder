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
end
