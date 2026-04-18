require_relative "support/cli_concat"

puts CLI.build(:curl)
  .X("POST")
  .H("Content-Type: application/json")
  .H("Authorization: Bearer token123")
  .d('{"name":"test"}')
  .("https://api.example.com/users")
  .to_s
# => curl -X POST -H Content-Type: application/json -H Authorization: Bearer token123 -d {"name":"test"} https://api.example.com/users

puts CLI.build(:curl).s(true).o("output.html").L(true).("https://example.com").to_s
# => curl -s -o output.html -L https://example.com

puts CLI.build(:curl)
  .X("PUT")
  .H("Content-Type: application/json")
  .d('@payload.json')
  .("https://api.example.com/users/1")
  .to_s
# => curl -X PUT -H Content-Type: application/json -d @payload.json https://api.example.com/users/1

puts CLI.build(:curl).I(true).("https://example.com").to_s
# => curl -I https://example.com

puts CLI.build(:curl)
  .X("DELETE")
  .H("Authorization: Bearer token123")
  .w("%{http_code}")
  .o("/dev/null")
  .s(true)
  .("https://api.example.com/users/1")
  .to_s
# => curl -X DELETE -H Authorization: Bearer token123 -w %{http_code} -o /dev/null -s https://api.example.com/users/1
