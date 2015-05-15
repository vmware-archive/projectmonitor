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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150515205647) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "btree_gin"
  enable_extension "btree_gist"
  enable_extension "citext"
  enable_extension "cube"
  enable_extension "dblink"
  enable_extension "dict_int"
  enable_extension "dict_xsyn"
  enable_extension "earthdistance"
  enable_extension "fuzzystrmatch"
  enable_extension "hstore"
  enable_extension "intarray"
  enable_extension "ltree"
  enable_extension "pg_stat_statements"
  enable_extension "pg_trgm"
  enable_extension "pgcrypto"
  enable_extension "pgrowlocks"
  enable_extension "pgstattuple"
  enable_extension "tablefunc"
  enable_extension "unaccent"
  enable_extension "uuid-ossp"
  enable_extension "xml2"

  create_table "aggregate_projects", force: true do |t|
    t.string   "name"
    t.boolean  "enabled",               default: true
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "code"
    t.string   "location",   limit: 20
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0
    t.integer  "attempts",   default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "queue"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "deprecated_sf_users_backup_20130220", id: false, force: true do |t|
    t.integer "id"
    t.string  "login", limit: 40
    t.string  "email", limit: 100
  end

  create_table "external_dependencies", force: true do |t|
    t.string   "name"
    t.string   "status"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "raw_response"
  end

  create_table "payload_log_entries", force: true do |t|
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "project_id"
    t.string   "status"
    t.string   "update_method"
    t.text     "error_text"
    t.text     "backtrace"
    t.string   "error_type"
  end

  add_index "payload_log_entries", ["created_at"], name: "index_payload_log_entries_on_created_at", using: :btree
  add_index "payload_log_entries", ["project_id", "created_at"], name: "index_payload_log_entries_on_project_id_and_created_at", using: :btree

  create_table "project_statuses", force: true do |t|
    t.boolean  "success",      default: false, null: false
    t.string   "url"
    t.datetime "published_at"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "error"
    t.integer  "build_id"
  end

  create_table "projects", force: true do |t|
    t.string   "name"
    t.string   "deprecated_feed_url"
    t.string   "auth_username"
    t.string   "auth_password"
    t.boolean  "enabled",                                            default: true
    t.boolean  "building",                                           default: false, null: false
    t.string   "type"
    t.integer  "aggregate_project_id"
    t.integer  "deprecated_latest_status_id"
    t.string   "code"
    t.string   "deprecated_location",                     limit: 20
    t.string   "tracker_project_id"
    t.string   "tracker_auth_token"
    t.integer  "current_velocity",                                   default: 0,     null: false
    t.string   "last_ten_velocities"
    t.boolean  "tracker_online"
    t.string   "cruise_control_rss_feed_url"
    t.string   "deprecated_jenkins_base_url"
    t.string   "deprecated_jenkins_build_name"
    t.string   "deprecated_team_city_base_url"
    t.string   "deprecated_team_city_build_id"
    t.string   "deprecated_team_city_rest_base_url"
    t.string   "deprecated_team_city_rest_build_type_id"
    t.string   "travis_github_account"
    t.string   "travis_repository"
    t.boolean  "online",                                             default: false
    t.string   "guid"
    t.boolean  "webhooks_enabled"
    t.string   "tracker_validation_status"
    t.datetime "last_refreshed_at"
    t.string   "semaphore_api_url"
    t.string   "parsed_url"
    t.string   "deprecated_tddium_auth_token"
    t.string   "deprecated_tddium_project_name"
    t.string   "notification_email"
    t.boolean  "verify_ssl",                                         default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "stories_to_accept_count"
    t.integer  "open_stories_count"
    t.string   "build_branch"
    t.text     "iteration_story_state_counts",                       default: "{}"
    t.integer  "creator_id"
    t.string   "deprecated_circleci_auth_token"
    t.string   "deprecated_circleci_project_name"
    t.string   "circleci_username"
    t.string   "deprecated_travis_pro_token"
    t.string   "deprecated_concourse_base_url"
    t.string   "deprecated_concourse_job_name"
    t.string   "ci_base_url"
    t.string   "ci_build_identifier"
    t.string   "ci_auth_token"
  end

  add_index "projects", ["aggregate_project_id"], name: "index_projects_on_aggregate_project_id", using: :btree

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: true do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "login",                  limit: 40
    t.string   "name",                   limit: 100, default: ""
    t.string   "email",                  limit: 100
    t.string   "encrypted_password",                 default: "", null: false
    t.string   "password_salt",          limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "provider"
    t.string   "uid"
  end

  add_index "users", ["login"], name: "index_users_on_login", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
