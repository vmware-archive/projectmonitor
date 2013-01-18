class AddRawStatusToExternalDependency < ActiveRecord::Migration
  def change
    add_column :external_dependencies, :raw_response, :string
  end
end
