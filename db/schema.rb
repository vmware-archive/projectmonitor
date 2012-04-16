# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120330185655) do

  create_table "aggregate_projects", :force => true do |t|
    t.string   "name"
    t.boolean  "enabled",    :default => true
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.string   "code"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.string   "queue"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "messages", :force => true do |t|
    t.string   "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "expires_at"
  end

  create_table "project_statuses", :force => true do |t|
    t.boolean  "online",       :default => false, :null => false
    t.boolean  "success",      :default => false, :null => false
    t.string   "url"
    t.datetime "published_at"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "error"
  end

  add_index "project_statuses", ["project_id", "online", "published_at"], :name => "index_project_statuses_on_project_id_and_others"

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.string   "feed_url"
    t.string   "auth_username"
    t.string   "auth_password"
    t.boolean  "enabled",               :default => true
    t.boolean  "building",              :default => false, :null => false
    t.string   "type"
    t.integer  "polling_interval"
    t.datetime "next_poll_at"
    t.integer  "aggregate_project_id"
    t.integer  "latest_status_id"
    t.boolean  "ec2_monday"
    t.boolean  "ec2_tuesday"
    t.boolean  "ec2_wednesday"
    t.boolean  "ec2_thursday"
    t.boolean  "ec2_friday"
    t.boolean  "ec2_saturday"
    t.boolean  "ec2_sunday"
    t.time     "ec2_start_time"
    t.time     "ec2_end_time"
    t.string   "ec2_access_key_id"
    t.string   "ec2_secret_access_key"
    t.string   "ec2_instance_id"
    t.string   "ec2_elastic_ip"
    t.string   "code"
  end

  add_index "projects", ["aggregate_project_id"], :name => "index_projects_on_aggregate_project_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "twitter_searches", :force => true do |t|
    t.string   "search_term"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
