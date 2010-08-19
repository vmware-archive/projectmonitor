#!/usr/bin/env ruby

def run(cmd)
  puts cmd
  system(cmd) || raise("Command Failed")
end

run "bundle install --relock"
run "RAILS_ENV=test rake db:create || true"
run "RAILS_ENV=test rake db:schema:load"
run "rake default"
