class RenameAllTravisUrlsFromXmlToJson < ActiveRecord::Migration
  def up
    execute <<-SQL
    UPDATE projects
    SET feed_url = REPLACE(feed_url, 'cc.xml', 'builds.json')
    WHERE type = 'TravisProject';
    SQL
  end

  def down
    execute <<-SQL
    UPDATE projects
    SET feed_url = REPLACE(feed_url, 'builds.json', 'cc.xml')
    WHERE type = 'TravisProject';
    SQL
  end
end
