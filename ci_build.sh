#!/usr/bin/env bash

source $HOME/.rvm/scripts/rvm && source .rvmrc

# install bundler if necessary
gem list --local bundler | grep bundler || gem install bundler || exit 1

# debugging info
echo USER=$USER && ruby --version && which ruby && which bundle

# conditionally install project gems from Gemfile
bundle check || bundle install --without postgres || exit 1

bundle exec rake setup
cp config/database.yml.travis config/database.yml

RAILS_ENV=test bundle exec rake db:create || true
RAILS_ENV=development bundle exec rake db:create || true

export DISPLAY=:99
/etc/init.d/xvfb start

bundle exec rake cruise