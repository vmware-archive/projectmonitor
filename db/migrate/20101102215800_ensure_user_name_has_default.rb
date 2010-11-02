class EnsureUserNameHasDefault < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.change :name, :string, :limit => 100, :default => ""
    end
  end

  def self.down
    t.change :name, :string
  end
end
