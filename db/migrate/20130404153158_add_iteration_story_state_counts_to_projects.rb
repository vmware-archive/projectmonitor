class AddIterationStoryStateCountsToProjects < ActiveRecord::Migration
  def change
    options = ActiveRecord::Base.connection.adapter_name.downcase.starts_with?("mysql") ? {} : { :default => "{}" }
    add_column :projects, :iteration_story_state_counts, :text, options
  end
end
