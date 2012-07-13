class DropMessagesAndTwitterSearches < ActiveRecord::Migration
  def up
    drop_table :messages
    drop_table :twitter_searches
  end

  def down
    create_table :twitter_searches do |t|
      t.string :search_term
      t.timestamps
    end

    create_table :messages do |t|
      t.string   :text
      t.timestamps
    end
  end
end
