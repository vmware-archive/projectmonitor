class AddVerifySslToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :verify_ssl, :boolean, default: true
  end
end
