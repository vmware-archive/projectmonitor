class AddIterationStoryStateCountsToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :iteration_story_state_counts, :text, :default => "{}"
  end
end
