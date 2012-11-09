require 'dbi'
require 'dbd/mysql'
require 'dbd/pg'

begin
  mysql = DBI.connect("DBI:Mysql:cimonitor_development:localhost", "root", "password")
  postgres = DBI.connect("DBI:Pg:projectmonitor_development:localhost", "root", "password")

  mysql.select_all("SHOW TABLES") do |table|
    table = table.first
    puts "Table: #{table}"
    next if ['schema_migrations', 'sessions'].include?(table.to_s)
    select = mysql.execute("SELECT * FROM #{table}")
    columns = select.column_names.map { |key| "\"#{key}\"" }.join(', ')
    placeholders = (['?'] * select.column_names.size).join(', ')
    insert = postgres.prepare("INSERT INTO #{table} (#{columns}) VALUES(#{placeholders})")
    select.each { |row| insert.execute(*row) }
    insert.finish
    postgres.execute("select setval('#{table}_id_seq', (select max(id) + 1 from #{table}));")
  end
rescue DBI::DatabaseError => e
  puts "Error #{e.err}: #{e.errstr}"
ensure
  mysql.disconnect if mysql
  postgres.disconnect if postgres
end
