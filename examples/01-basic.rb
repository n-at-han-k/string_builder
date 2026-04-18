require_relative "../lib/string_builder"

# ──────────────────────────────────────────────────────────────────
# StringBuilder turns Ruby method chains into strings.
# Every method call becomes a token. Arguments get serialized.
# That's it. That's the whole idea — and it's absurdly powerful.
# ──────────────────────────────────────────────────────────────────

# --- Blockless chaining (returns a StringBuilder you keep building) ---

sb = StringBuilder.new.get.deployment
puts sb.to_s
# => "get deployment"

sb = StringBuilder.new.create.namespace.production
puts sb.to_s
# => "create namespace production"

# --- Arguments become part of the token ---

sb = StringBuilder.new.get.pods.namespace("kube-system")
puts sb.to_s
# => "get pods namespace(\"kube-system\")"

sb = StringBuilder.new.scale.deployment("web", replicas: 5)
puts sb.to_s
# => "scale deployment(\"web\", {replicas: 5})"

# --- Keyword arguments ---

sb = StringBuilder.new.deploy(image: "nginx", tag: "latest")
puts sb.to_s
# => "deploy({image: \"nginx\", tag: \"latest\"})"

# --- Scoped blocks: wrap {} gives you a clean DSL context ---

sb = StringBuilder.new.wrap { get.pods.namespace("default") }
puts sb.to_s
# => "get pods namespace(\"default\")"

# Inside wrap, each top-level call starts a fresh token chain.
# This means multi-statement blocks build multi-line token sequences:

sb = StringBuilder.new.wrap {
  get.pods
  apply.f("deployment.yaml")
}
puts sb.to_s
# => "get pods apply f(\"deployment.yaml\")"

# --- Operators: / and - work as literal separators ---

sb = StringBuilder.new.wrap { get.deployment/v1/apps }
puts sb.to_s
# => "get deployment / v1 / apps"

sb = StringBuilder.new.wrap { get.kube-proxy }
puts sb.to_s
# => "get kube - proxy"

# --- .call() injects raw strings (no method_missing parsing) ---

sb = StringBuilder.new.get.("deployment/v1/apps").all
puts sb.to_s
# => "get deployment/v1/apps all"

sb = StringBuilder.new.run.("--dry-run=client").output("yaml")
puts sb.to_s
# => "run --dry-run=client output(\"yaml\")"

# --- Integer monkey-patch: numbers chain naturally ---

token = 3.px
puts token.to_a.inspect
# => [["3", []], ["px", []]]

sb = StringBuilder.new.wrap { margin.top / 10.px }
puts sb.to_s
# => "margin top / 10 px"

# --- Enumerable: iterate over the buffer ---

sb = StringBuilder.new.get.pods.namespace("default")
puts sb.map { |name, args| args.empty? ? name : "#{name}=#{args.first}" }.join(" ")
# => "get pods namespace=default"

puts sb.count.to_s
# => 3

puts sb.to_a.inspect
# => [["get", []], ["pods", []], ["namespace", ["default"]]]
