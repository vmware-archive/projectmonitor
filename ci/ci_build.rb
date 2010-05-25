#!/usr/bin/env ruby

def run(cmd)
  puts cmd
  system(cmd) || raise("Command Failed")
end

run "bundle install --relock"
run "rake db:migrate"
run "rake db:schema:load RAILS_ENV=test"
run "rake default"
