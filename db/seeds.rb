# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

# Create or update the admin user
# The credentials can be specified through environment variables or by changing the default values below.
login = ENV["PROJECT_MONITOR_LOGIN"] || "admin"
email = ENV["PROJECT_MONITOR_EMAIL"] || "admin@example.com"
password = ENV["PROJECT_MONITOR_PASSWORD"] || "password"

user = User.where(login: login).first_or_initialize
user.update(email: email, password: password)
user.save
