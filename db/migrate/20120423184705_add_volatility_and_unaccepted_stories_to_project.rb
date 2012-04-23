class AddVolatilityAndUnacceptedStoriesToProject < ActiveRecord::Migration
  def change
    add_column :projects, :tracker_volatility, :integer, default: 0, null: false
    add_column :projects, :tracker_num_unaccepted_stories, :integer, default: 0, null: false
  end
end
