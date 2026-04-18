require_relative "support/cli_concat"

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
