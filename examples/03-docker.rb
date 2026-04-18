require_relative "support/cli_concat"

puts CLI.build(:docker).run.d(true).name("web").p("8080:80").("nginx:latest").to_s
# => docker run -d --name web -p 8080:80 nginx:latest

puts CLI.build(:docker)
  .build
  .t("myapp:latest")
  .f("Dockerfile.prod")
  .build_arg("VERSION=1.0")
  .no_cache(true)
  .(".")
  .to_s
# => docker build -t myapp:latest -f Dockerfile.prod --build-arg VERSION=1.0 --no-cache .

puts CLI.build(:docker).compose.up.d(true).build(true).remove_orphans(true).to_s
# => docker compose up -d --build --remove-orphans

puts CLI.build(:docker).volume.create.name("pgdata").to_s
# => docker volume create --name pgdata

puts CLI.build(:docker).network.create.driver("overlay").("my-network").to_s
# => docker network create --driver overlay my-network

puts CLI.build(:docker).logs.f(true).tail(100).("my-container").to_s
# => docker logs -f --tail 100 my-container
