class CreateTwitterSearches < ActiveRecord::Migration
  def self.up
    create_table :twitter_searches do |t|
      t.string :search_term

      t.timestamps
    end
  end

  def self.down
    drop_table :twitter_searches
  end
end
