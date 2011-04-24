#!/usr/bin/env bash

source $HOME/.rvm/scripts/rvm && source .rvmrc

# install bundler if necessary
gem list --local bundler | grep bundler || gem install bundler || exit 1

# debugging info
echo USER=$USER && ruby --version && which ruby && which bundle

# conditionally install project gems from Gemfile
bundle check || bundle install --without postgres || exit 1

rake setup

RAILS_ENV=test rake db:create || true
RAILS_ENV=development rake db:create || true

rake cruise