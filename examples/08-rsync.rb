require_relative "support/cli_concat"

puts CLI.build(:rsync)
  .a(true).v(true).z(true)
  .progress(true)
  .exclude(".git")
  .exclude("node_modules")
  .("./src/")
  .("deploy@prod:/var/www/app/")
  .to_s
# => rsync -a -v -z --progress --exclude .git --exclude node_modules ./src/ deploy@prod:/var/www/app/

puts CLI.build(:rsync)
  .a(true)
  .delete(true)
  .exclude("*.log")
  .("./build/")
  .("deploy@staging:/opt/app/")
  .to_s
# => rsync -a --delete --exclude *.log ./build/ deploy@staging:/opt/app/

puts CLI.build(:rsync)
  .a(true).v(true)
  .e("ssh -p 2222")
  .("./data/")
  .("backup@remote:/backups/")
  .to_s
# => rsync -a -v -e ssh -p 2222 ./data/ backup@remote:/backups/
