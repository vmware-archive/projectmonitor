class AddParsedUrlToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :parsed_url, :string
  end
end
