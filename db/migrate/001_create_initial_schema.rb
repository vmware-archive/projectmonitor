class CreateInitialSchema < ActiveRecord::Migration
  def self.up
    create_table "messages", :force => true do |t|
      t.string   "text"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "project_statuses", :force => true do |t|
      t.boolean  "online",       :default => false, :null => false
      t.boolean  "success",      :default => false, :null => false
      t.string   "url"
      t.datetime "published_at"
      t.integer  "project_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "error"
    end

    create_table "projects", :force => true do |t|
      t.string  "name"
      t.string  "cc_rss_url"
      t.string  "auth_username"
      t.string  "auth_password"
      t.boolean "enabled",       :default => true
      t.boolean "building",      :default => false, :null => false
    end

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

  def self.down
    raise IrreversibleMigration
  end
end
