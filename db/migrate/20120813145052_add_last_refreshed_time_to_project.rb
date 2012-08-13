class AddLastRefreshedTimeToProject < ActiveRecord::Migration
  def change
    add_column :projects, :last_refreshed_at, :datetime
  end
end
