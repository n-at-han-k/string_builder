require_relative "../lib/string_builder"

# ──────────────────────────────────────────────────────────────────
# CLI Command Builder
#
# This is the use case that StringBuilder was born for.
# A single concat handler that understands CLI flag conventions
# turns Ruby method chains into shell commands for ANY CLI tool.
#
# Convention:
#   - Single-char methods become short flags:     .f("file") -> -f file
#   - Multi-char methods become long flags:        .output("json") -> --output json
#   - true args become boolean flags:              .force(true) -> --force
#   - Bare methods become subcommands/args:        .get.pods -> get pods
#   - Underscores become hyphens in flags:         .dry_run(true) -> --dry-run
#   - .call() injects raw tokens:                  .("literal") -> literal
#   - Hash args become key=value:                  .l(app: "web") -> -l app=web
#   - Symbols stay unquoted:                       .o(:json) -> -o json
# ──────────────────────────────────────────────────────────────────

module CLI
  class Concat
    def self.call(buffer) = new(buffer).render

    def initialize(buffer) = @buffer = buffer

    def render
      @buffer.filter_map { |entry|
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
      return name if args.empty?

      # Hash arguments: -l app=web or --selector app=web
      if args.length == 1 && args.first.is_a?(Hash)
        flag = flag_for(name)
        kv = args.first.map { |k, v| "#{k}=#{v}" }.join(",")
        return "#{flag} #{kv}"
      end

      # Boolean true: --force (no value)
      return flag_for(name) if args == [true]

      # Boolean false: skip entirely
      return nil if args == [false]

      # Regular flag with value(s)
      flag = flag_for(name)
      vals = args.map { |a| a.is_a?(Symbol) ? a.to_s : a.to_s }
      "#{flag} #{vals.join(',')}"
    end

    def flag_for(name)
      dashed = name.tr("_", "-")
      dashed.length == 1 ? "-#{dashed}" : "--#{dashed}"
    end
  end

  # Blockless builder — returns a StringBuilder you chain on directly.
  # Avoids method_missing collisions (exec, system, etc.) inside wrap blocks.
  def self.build(tool)
    sb = StringBuilder.new { |buf|
      "#{tool} #{Concat.call(buf)}"
    }
    sb
  end
end

# ──────────────────────────────────────────────────────────────────
# Git
# ──────────────────────────────────────────────────────────────────

puts CLI.build(:git).commit.m("fix: resolve null pointer in parser").to_s
# => git commit -m fix: resolve null pointer in parser

puts CLI.build(:git).push.origin.main.force(true).to_s
# => git push origin main --force

puts CLI.build(:git).log.oneline(true).graph(true).all(true).n(20).to_s
# => git log --oneline --graph --all -n 20

puts CLI.build(:git).remote.add.origin.("git@github.com:user/repo.git").to_s
# => git remote add origin git@github.com:user/repo.git

puts CLI.build(:git).stash.push.m("wip: feature branch save").to_s
# => git stash push -m wip: feature branch save

puts CLI.build(:git).diff.stat(true).cached(true).to_s
# => git diff --stat --cached

puts CLI.build(:git).rebase.i(true).("HEAD~5").to_s
# => git rebase -i HEAD~5

puts CLI.build(:git).tag.a("v1.0.0").m("Release 1.0.0").to_s
# => git tag -a v1.0.0 -m Release 1.0.0

puts CLI.build(:git).branch.d(true).("feature/old-branch").to_s
# => git branch -d feature/old-branch

puts ""

# ──────────────────────────────────────────────────────────────────
# Docker
# ──────────────────────────────────────────────────────────────────

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

puts ""

# ──────────────────────────────────────────────────────────────────
# FFmpeg
# ──────────────────────────────────────────────────────────────────

puts CLI.build(:ffmpeg)
  .i("input.mp4")
  .vf("scale=1920:1080")
  .c(:v, :libx264)
  .crf(23)
  .preset(:fast)
  .("output.mp4")
  .to_s
# => ffmpeg -i input.mp4 --vf scale=1920:1080 -c v,libx264 --crf 23 --preset fast output.mp4

puts CLI.build(:ffmpeg)
  .i("video.mkv")
  .ss("00:01:30")
  .t("00:00:45")
  .c(:copy)
  .("clip.mkv")
  .to_s
# => ffmpeg -i video.mkv --ss 00:01:30 -t 00:00:45 -c copy clip.mkv

puts ""

# ──────────────────────────────────────────────────────────────────
# Curl
# ──────────────────────────────────────────────────────────────────

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

puts ""

# ──────────────────────────────────────────────────────────────────
# Rsync
# ──────────────────────────────────────────────────────────────────

puts CLI.build(:rsync)
  .a(true).v(true).z(true)
  .progress(true)
  .exclude(".git")
  .exclude("node_modules")
  .("./src/")
  .("deploy@prod:/var/www/app/")
  .to_s
# => rsync -a -v -z --progress --exclude .git --exclude node_modules ./src/ deploy@prod:/var/www/app/

puts ""

# ──────────────────────────────────────────────────────────────────
# Terraform
# ──────────────────────────────────────────────────────────────────

puts CLI.build(:terraform).plan.var("region=us-east-1").var_file("prod.tfvars").out("plan.out").to_s
# => terraform plan --var region=us-east-1 --var-file prod.tfvars --out plan.out

puts CLI.build(:terraform).apply.auto_approve(true).("plan.out").to_s
# => terraform apply --auto-approve plan.out

puts CLI.build(:terraform).destroy.auto_approve(true).target("aws_instance.web").to_s
# => terraform destroy --auto-approve --target aws_instance.web

puts ""

# ──────────────────────────────────────────────────────────────────
# AWS CLI
# ──────────────────────────────────────────────────────────────────

puts CLI.build(:aws).s3.cp.("s3://my-bucket/data.csv").(".").recursive(true).to_s
# => aws s3 cp s3://my-bucket/data.csv . --recursive

puts CLI.build(:aws).ec2.describe_instances.region("us-east-1").output(:json).to_s
# => aws ec2 --describe-instances --region us-east-1 --output json

puts CLI.build(:aws).ecs.update_service
  .cluster("prod")
  .service("web")
  .force_new_deployment(true)
  .to_s
# => aws ecs --update-service --cluster prod --service web --force-new-deployment

puts ""

# ──────────────────────────────────────────────────────────────────
# ~70 lines of concat logic. Every CLI tool on the planet.
# ──────────────────────────────────────────────────────────────────
