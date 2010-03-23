class AddSupportForOtherFormats < ActiveRecord::Migration
  def self.up
    change_table :projects do |t|
      t.rename :cc_rss_url, :feed_url
      t.string :type, :default => 'CruiseControlProject', :null => false
    end
  end

  def self.down
    change_table :projects do |t|
      t.rename :feed_url, :cc_rss_url
      t.remove :type
    end
  end
end
