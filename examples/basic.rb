require_relative "../lib/string_builder"

# Simple method chaining
sb = StringBuilder.new.get.deployment
puts sb.to_s
# => "get.deployment"

# Method chaining with arguments
sb = StringBuilder.new.get.deployment.namespace("default")
puts sb.to_s
# => "get.deployment.namespace(\"default\")"

# Block-style usage
sb = StringBuilder.new.wrap { get.pods.namespace("kube-system") }
puts sb.to_s
# => "get.pods.namespace(\"kube-system\")"

# Slash operator for paths
sb = StringBuilder.new.wrap { get.deployment/v1/apps }
puts sb.to_s

# Dash operator for hyphenated names
sb = StringBuilder.new.wrap { get.node.k8s-node }
puts sb.to_s

# Integer method chaining
token = 1.app
puts token.to_s
# => "1.app"

# .call() to inject raw strings into the chain
sb = StringBuilder.new.get.("deployment/v1/apps").all
puts sb.to_s
