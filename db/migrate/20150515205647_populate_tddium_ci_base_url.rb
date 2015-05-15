class PopulateTddiumCiBaseUrl < ActiveRecord::Migration
  FALLBACK_MESSAGE = 'This was invalid data. Please change me to the real URL.  See https://www.pivotaltracker.com/story/show/94431820'

  def up
    execute <<-SQL
      UPDATE projects
      SET ci_base_url = '#{FALLBACK_MESSAGE}'
      WHERE ci_base_url is null
      AND type = 'TddiumProject';
    SQL
  end

  def down
    execute <<-SQL
      UPDATE projects
      SET ci_base_url = null
      WHERE ci_base_url is '#{FALLBACK_MESSAGE}';
    SQL
  end
end
