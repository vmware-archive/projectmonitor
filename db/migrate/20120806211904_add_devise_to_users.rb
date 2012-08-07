class AddDeviseToUsers < ActiveRecord::Migration
  def self.up
    change_table(:users) do |t|
      t.rename :crypted_password, :encrypted_password
      t.rename :salt, :password_salt

      ## Database authenticatable
      t.change :encrypted_password, :string, null: false, default: '', limit: nil

      ## Recoverable
      t.string :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at
      t.remove :remember_token
      t.remove :remember_token_expires_at

      ## Trackable
      t.integer :sign_in_count, default: 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string :current_sign_in_ip
      t.string :last_sign_in_ip
    end

    add_index :users, :reset_password_token, unique: true
  end

  def self.down
    remove_index :users, :reset_password_token

    change_table(:users) do |t|
      t.remove :last_sign_in_ip
      t.remove :current_sign_in_ip
      t.remove :last_sign_in_at
      t.remove :current_sign_in_at
      t.remove :sign_in_count
      t.datetime :remember_token_expires_at
      t.string :remember_token, limit: 40
      t.remove :remember_created_at
      t.remove :reset_password_sent_at
      t.remove :reset_password_token
      t.change :encrypted_password, :string, limit: 40, null: true, default: nil
      t.rename :password_salt, :salt
      t.rename :encrypted_password, :crypted_password
    end
  end
end
