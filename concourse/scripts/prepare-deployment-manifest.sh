#!/usr/bin/env bash

set -ex

cd project-monitor-repo

cp config/database.yml.example config/database.yml

sed -i -e 's/${HOST}/'"$PROJECTMONITOR_HOST"'/' manifest.yml
sed -i -e 's/${DOMAIN}/'"$PROJECTMONITOR_DOMAIN"'/' manifest.yml

cp -a . ../prepared-deployment