class AddExpiryToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :expires_at, :datetime
  end

  def self.down
    remove_column :messages, :expires_at
  end
end
