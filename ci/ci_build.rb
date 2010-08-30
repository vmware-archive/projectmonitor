#!/usr/bin/env ruby

def run(cmd)
  puts "=> #{cmd}"
  system(cmd) || raise("Command Failed")
end

begin
  run "bundle check"
rescue
  run "bundle install --relock"
end
run "rake db:migrate"
run "rake db:schema:load RAILS_ENV=test"
run "rake default"
