#!/usr/bin/env ruby

def run(cmd)
  puts cmd
  system(cmd) || raise("Command Failed")
end

run "bundle install --relock"
run "rake db:migrate RAILS_ENV=test"
run "rake db:test:prepare"
run "rake default"
