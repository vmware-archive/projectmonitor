class AddTravisProTokenToProject < ActiveRecord::Migration
  def change
    add_column :projects, :travis_pro_token, :string
  end
end
