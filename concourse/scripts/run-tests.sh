#!/usr/bin/env bash

set -ex

cd project-monitor-repo

bundle install

cp config/database.yml.example config/database.yml

# https://github.com/opsxcq/docker-vulnerable-dvwa/issues/3 mysql does not start without "touching" the /mysql files
chown -R mysql:mysql /var/lib/mysql && service mysql start

RAILS_ENV=test rake db:create
RAILS_ENV=test rake db:migrate

xvfb-run -a rake spec