class AddWebhookToggleToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :webhooks_enabled, :boolean
  end
end
