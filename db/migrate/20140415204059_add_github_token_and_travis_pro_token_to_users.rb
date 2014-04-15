class AddGithubTokenAndTravisProTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :github_token, :string
    add_column :users, :travis_pro_token, :string
  end
end
