class CreateExternalDependencies < ActiveRecord::Migration
  def change
    create_table :external_dependencies do |t|
      t.string :name
      t.string :status

      t.timestamps
    end
  end
end
