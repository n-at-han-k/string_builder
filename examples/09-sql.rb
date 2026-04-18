require_relative "../lib/string_builder"

# ──────────────────────────────────────────────────────────────────
# SQL Query Builder
#
# A concat handler that renders SQL syntax from method chains.
# ──────────────────────────────────────────────────────────────────

module SQL
  class Concat
    KEYWORDS = %w[select from where join on and or order_by group_by having limit offset
                  inner_join left_join right_join insert into values update set delete
                  create table drop alter add column index distinct count sum avg min max
                  as between like in not null is union all exists case when then else end
                  columns grouped_by sorted_by counted].freeze

    ALIASES = { "columns" => "SELECT", "grouped_by" => "GROUP BY",
                "sorted_by" => "ORDER BY", "counted" => "COUNT" }.freeze

    def self.call(buffer) = new(buffer).render

    def initialize(buffer) = @buffer = buffer

    def render
      @buffer.map { |entry|
        case entry
        when :slash then "/"
        when :dash then "-"
        else
          name, args = entry
          format_token(name, args)
        end
      }.join(" ")
    end

    private

    def format_token(name, args)
      keyword = ALIASES[name] || name.tr("_", " ").upcase
      return keyword if args.empty?

      values = args.map { |arg|
        case arg
        when Symbol then arg.to_s
        when String then "'#{arg}'"
        when Hash then arg.map { |k, v| "#{k} = #{format_value(v)}" }.join(" AND ")
        when Numeric then arg.to_s
        when TrueClass then "TRUE"
        when FalseClass then "FALSE"
        else arg.inspect
        end
      }

      "#{keyword} #{values.join(', ')}"
    end

    def format_value(v)
      case v
      when String then "'#{v}'"
      when Symbol then v.to_s
      when nil then "NULL"
      when TrueClass then "TRUE"
      when FalseClass then "FALSE"
      else v.to_s
      end
    end
  end

  def self.query(&block)
    sb = StringBuilder.new { |buf| Concat.call(buf) }
    block ? sb.wrap(&block).to_s : sb
  end
end

# ──────────────────────────────────────────────────────────────────

puts SQL.query { columns(:name, :email).from("users") }
# => SELECT name, email FROM 'users'

puts SQL.query { columns(:name).from("users").where(active: true, role: "admin") }
# => SELECT name FROM 'users' WHERE active = TRUE AND role = 'admin'

puts SQL.query {
  columns(:u_name, :o_total)
    .from("users u")
    .inner_join("orders o")
    .on("u.id = o.user_id")
}
# => SELECT u_name, o_total FROM 'users u' INNER JOIN 'orders o' ON 'u.id = o.user_id'

puts SQL.query {
  columns(:department)
    .counted(:id)
    .from("employees")
    .grouped_by(:department)
    .having("count > 5")
    .sorted_by(:department)
}
# => SELECT department COUNT 'id' FROM 'employees' GROUP BY department HAVING 'count > 5' ORDER BY department

puts SQL.query { insert.into("users").values("alice", "alice@example.com", 28) }
# => INSERT INTO 'users' VALUES 'alice', 'alice@example.com', 28

puts SQL.query { update("users").set(name: "bob", email: "bob@example.com").where(id: 1) }
# => UPDATE 'users' SET name = 'bob' AND email = 'bob@example.com' WHERE id = 1

puts SQL.query { delete.from("sessions").where(expired: true) }
# => DELETE FROM 'sessions' WHERE expired = TRUE

puts SQL.query {
  columns(:id, :name)
    .from("products")
    .where(category: "electronics")
    .order_by(:price)
    .limit(10)
    .offset(20)
}
# => SELECT id, name FROM 'products' WHERE category = 'electronics' ORDER BY price LIMIT 10 OFFSET 20

puts SQL.query {
  columns(:u_name, :p_avatar)
    .from("users u")
    .left_join("profiles p")
    .on("u.id = p.user_id")
    .where(u_active: true)
}
# => SELECT u_name, p_avatar FROM 'users u' LEFT JOIN 'profiles p' ON 'u.id = p.user_id' WHERE u_active = TRUE

puts SQL.query { columns.distinct(:status).from("orders") }
# => SELECT DISTINCT status FROM 'orders'
