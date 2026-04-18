# frozen_string_literal: true

require "test_helper"

class StringBuilderTest < Minitest::Test
  def sb(&block)
    StringBuilder.new.tap { |s| s.instance_eval(&block) if block }
  end

  def assert_buffer(result, expected)
    assert_equal expected, result.buffer
  end

  def test_get
    result = sb { get }
    assert_buffer(result, [["get", []]])
  end

  def test_get_deployment
    result = sb { get.deployment }
    assert_buffer(result, [["get", []], ["deployment", []]])
  end

  def test_get_deployment_slash_v1
    result = sb { get.deployment/v1 }
    assert_buffer(result, [["get", []], ["deployment", []], ["v1", []], :slash])
  end

  def test_get_deployment_slash_v1_slash_app
    result = sb { get.deployment/v1/app }
    assert_buffer(result, [["get", []], ["deployment", []], ["v1", []], :slash, ["app", []], :slash])
  end

  def test_get_deployment_slash_v1_slash_app_namespace
    result = sb { get.deployment/v1/app.namespace("default") }
    assert_buffer(
      result,
      [
        ["get", []], ["deployment", []], ["v1", []], :slash,
        ["app", []], ["namespace", ["default"]], :slash
      ]
    )
  end

  def test_dash_operator_marks_dash_token
    result = sb { get.node.k8s-node }
    assert_buffer(result, [["get", []], ["node", []], ["k8s", []], ["node", []], :dash])
  end

  def test_blockless_chaining
    result = StringBuilder.new.get.deployment
    assert_buffer(result, [["get", []], ["deployment", []]])
  end

  def test_call_with_string_arg
    result = StringBuilder.new.get.("deployment/v1/apps")
    assert_buffer(result, [["get", []], ["deployment/v1/apps", []]])
  end

  def test_call_with_string_arg_then_chain
    result = StringBuilder.new.get.("deployment/v1/apps").all
    assert_buffer(result, [["get", []], ["deployment/v1/apps", []], ["all", []]])
  end

  def test_call_with_no_args_raises
    assert_raises(ArgumentError) do
      StringBuilder.new.get.()
    end
  end
end
