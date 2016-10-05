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

ActiveRecord::Schema.define(version: 20161005175656) do

  create_table "aggregate_projects", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.boolean  "enabled",                default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code",       limit: 255
    t.string   "location",   limit: 20
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0
    t.integer  "attempts",   limit: 4,     default: 0
    t.text     "handler",    limit: 65535
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "queue",      limit: 255
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "external_dependencies", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "status",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "raw_response", limit: 255
  end

  create_table "payload_log_entries", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id",    limit: 4
    t.string   "status",        limit: 255
    t.string   "update_method", limit: 255
    t.text     "error_text",    limit: 65535
    t.text     "backtrace",     limit: 65535
    t.string   "error_type",    limit: 255
  end

  add_index "payload_log_entries", ["created_at"], name: "index_payload_log_entries_on_created_at", using: :btree
  add_index "payload_log_entries", ["project_id", "created_at"], name: "index_payload_log_entries_on_project_id_and_created_at", using: :btree

  create_table "project_statuses", force: :cascade do |t|
    t.boolean  "success",                    default: false, null: false
    t.string   "url",          limit: 255
    t.datetime "published_at"
    t.integer  "project_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "error",        limit: 65535
    t.integer  "build_id",     limit: 4
  end

  add_index "project_statuses", ["project_id", "published_at"], name: "index_project_statuses_on_project_id_and_others", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "name",                                    limit: 255
    t.string   "deprecated_feed_url",                     limit: 255
    t.string   "auth_username",                           limit: 255
    t.string   "auth_password",                           limit: 255
    t.boolean  "enabled",                                               default: true
    t.boolean  "building",                                              default: false, null: false
    t.string   "type",                                    limit: 255
    t.integer  "aggregate_project_id",                    limit: 4
    t.integer  "deprecated_latest_status_id",             limit: 4
    t.string   "code",                                    limit: 255
    t.string   "deprecated_location",                     limit: 20
    t.string   "tracker_project_id",                      limit: 255
    t.string   "tracker_auth_token",                      limit: 255
    t.integer  "current_velocity",                        limit: 4,     default: 0,     null: false
    t.string   "last_ten_velocities",                     limit: 255
    t.boolean  "tracker_online"
    t.string   "cruise_control_rss_feed_url",             limit: 255
    t.string   "deprecated_jenkins_base_url",             limit: 255
    t.string   "deprecated_jenkins_build_name",           limit: 255
    t.string   "deprecated_team_city_base_url",           limit: 255
    t.string   "deprecated_team_city_build_id",           limit: 255
    t.string   "deprecated_team_city_rest_base_url",      limit: 255
    t.string   "deprecated_team_city_rest_build_type_id", limit: 255
    t.string   "travis_github_account",                   limit: 255
    t.string   "travis_repository",                       limit: 255
    t.boolean  "online",                                                default: false
    t.string   "guid",                                    limit: 255
    t.boolean  "webhooks_enabled"
    t.string   "tracker_validation_status",               limit: 255
    t.datetime "last_refreshed_at"
    t.string   "semaphore_api_url",                       limit: 255
    t.string   "parsed_url",                              limit: 255
    t.string   "deprecated_tddium_auth_token",            limit: 255
    t.string   "deprecated_tddium_project_name",          limit: 255
    t.string   "notification_email",                      limit: 255
    t.boolean  "verify_ssl",                                            default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "stories_to_accept_count",                 limit: 4
    t.integer  "open_stories_count",                      limit: 4
    t.string   "build_branch",                            limit: 255
    t.text     "iteration_story_state_counts",            limit: 65535
    t.integer  "creator_id",                              limit: 4
    t.string   "deprecated_circleci_auth_token",          limit: 255
    t.string   "deprecated_circleci_project_name",        limit: 255
    t.string   "circleci_username",                       limit: 255
    t.string   "deprecated_travis_pro_token",             limit: 255
    t.string   "deprecated_concourse_base_url",           limit: 255
    t.string   "deprecated_concourse_job_name",           limit: 255
    t.string   "ci_base_url",                             limit: 255
    t.string   "ci_build_identifier",                     limit: 255
    t.string   "ci_auth_token",                           limit: 255
    t.string   "concourse_pipeline_name",                 limit: 255
  end

  add_index "projects", ["aggregate_project_id"], name: "index_projects_on_aggregate_project_id", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",        limit: 4
    t.integer  "taggable_id",   limit: 4
    t.string   "taggable_type", limit: 255
    t.datetime "created_at"
    t.integer  "tagger_id",     limit: 4
    t.string   "tagger_type",   limit: 255
    t.string   "context",       limit: 255
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "taggings_count", limit: 4,   default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "login",                  limit: 40
    t.string   "name",                   limit: 100, default: ""
    t.string   "email",                  limit: 100
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "password_salt",          limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "provider",               limit: 255
    t.string   "uid",                    limit: 255
  end

  add_index "users", ["login"], name: "index_users_on_login", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
