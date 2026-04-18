# frozen_string_literal: true

require "test_helper"

class StringBuilderTest < Minitest::Test
  def sb(&block)
    StringBuilder.new.tap { |s| s.instance_eval(&block) if block }
  end

  def assert_buffer(result, expected)
    assert_equal expected, result.buffer
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

  def test_get_deployment_slash_v1
    result = sb { get.deployment/v1 }
    assert_buffer(result, [["get", []], ["deployment", []], :slash, ["v1", []]])
    assert_string(result, "get deployment / v1")
  end

  def test_get_deployment_slash_v1_slash_app
    result = sb { get.deployment/v1/app }
    assert_buffer(result, [["get", []], ["deployment", []], :slash, ["v1", []], :slash, ["app", []]])
    assert_string(result, "get deployment / v1 / app")
  end

  def test_get_deployment_slash_v1_slash_app_namespace
    result = sb { get.deployment/v1/app.namespace("default") }
    assert_buffer(
      result,
      [
        ["get", []], ["deployment", []], :slash, ["v1", []], :slash,
        ["app", []], ["namespace", ["default"]]
      ]
    )
    assert_string(result, "get deployment / v1 / app namespace(\"default\")")
  end

  def test_dash_operator_marks_dash_token
    result = sb { get.node.k8s-node }
    assert_buffer(result, [["get", []], ["node", []], ["k8s", []], :dash, ["node", []]])
    assert_string(result, "get node k8s - node")
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
end
