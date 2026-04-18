class ::Integer
  def method_missing(name, *args, &_block)
    return super unless name.to_s.match?(/\A[a-z_][a-z0-9_]*\z/)

    MethodCallToken.new(self, name, args)
  end

  def respond_to_missing?(name, include_private = false)
    name.to_s.match?(/\A[a-z_][a-z0-9_]*\z/) || super
  end

  def to_str
    to_s
  end
end
