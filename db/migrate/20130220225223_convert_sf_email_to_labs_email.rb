class ConvertSfEmailToLabsEmail < ActiveRecord::Migration
  def up
    execute(<<-SQL)
      CREATE TABLE deprecated_sf_users_backup_20130220 AS
        SELECT id,login,email FROM users WHERE email ILIKE '%pivotalsf.com';

      UPDATE users SET email = login || '@pivotallabs.com' WHERE email ILIKE '%pivotalsf.com';
    SQL
  end

  def down
    execute(<<-SQL)
      UPDATE users SET email = old.email
        FROM deprecated_sf_users_backup_20130220 old
        WHERE users.id = old.id;

      DROP TABLE deprecated_sf_users_backup_20130220;
    SQL
  end
end
