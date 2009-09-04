class CreateInitialSchema < ActiveRecord::Migration
  def self.up
    create_table "asset_version_states", :force => true do |t|
      t.string "name"
      t.string "display_name"
    end

    create_table "asset_versions", :force => true do |t|
      t.string   "version"
      t.integer  "asset_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "state_id"
      t.string   "filename"
      t.string   "mime_type"
      t.string   "uri"
      t.string   "type"
      t.float    "percent_completed"
      t.string   "state_info"
    end

    create_table "assets", :force => true do |t|
      t.text     "type"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "position"
      t.integer  "creator_id"
      t.string   "source_uri"
      t.string   "original_filename"
    end

    add_index "assets", ["creator_id", "created_at", "id"], :name => "index_assets_on_creator_id_and_created_at_and_id"
    add_index "assets", ["id"], :name => "index_assets_on_id"

    create_table "assets_associations", :force => true do |t|
      t.integer  "asset_id"
      t.integer  "associate_id"
      t.string   "associate_type"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "position"
      t.string   "type"
      t.boolean  "primary"
    end

    add_index "assets_associations", ["asset_id", "associate_type", "associate_id", "position"], :name => "asset_associate_position"
    add_index "assets_associations", ["associate_id"], :name => "index_assets_associations_on_associate_id"

    create_table "association_shims", :force => true do |t|
      t.string "name"
    end

    create_table "email_addresses", :force => true do |t|
      t.string   "address"
      t.integer  "user_id"
      t.boolean  "verified"
      t.boolean  "primary"
      t.datetime "updated_at"
      t.datetime "created_at"
      t.datetime "deleted_at"
    end

    add_index "email_addresses", ["address", "deleted_at"], :name => "index_email_addresses_on_address_and_deleted_at"
    add_index "email_addresses", ["user_id", "primary", "deleted_at"], :name => "index_email_addresses_on_user_id_and_primary_and_deleted_at"

    create_table "logins", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "user_id"
      t.datetime "deleted_at"
    end

    add_index "logins", ["user_id", "deleted_at", "updated_at"], :name => "index_logins_on_user_id_and_deleted_at_and_updated_at"

    create_table "messages", :force => true do |t|
      t.string   "text"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "plugin_schema_migrations", :id => false, :force => true do |t|
      t.string "plugin_name"
      t.string "version"
    end

    create_table "profiles", :force => true do |t|
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "first_name"
      t.string   "last_name"
      t.date     "date_of_birth"
      t.datetime "deleted_at"
    end

    add_index "profiles", ["user_id", "deleted_at"], :name => "index_profiles_on_user_id_and_deleted_at"

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

    create_table "terms_of_services", :force => true do |t|
      t.text     "text"
      t.integer  "revision"
      t.datetime "created_at"
    end

    create_table "tokens", :force => true do |t|
      t.integer  "tokenable_id"
      t.string   "type"
      t.string   "guid"
      t.datetime "expires_at"
      t.datetime "created_at"
      t.boolean  "used",           :default => false
      t.string   "tokenable_type"
      t.datetime "updated_at"
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
