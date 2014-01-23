require 'active_record'
require 'database_cleaner'

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
load 'db/schema.rb'

module ActiveRecordSpecHelper
  def self.included(obj)
    before do
      begin
        DatabaseCleaner.start
      rescue ActiveRecord::StatementInvalid
        # Due to a PostgreSQL lock on referenced tables, ActiveRecord throws an exception occasionally
        # So, catch the exception and try to clean again. By this time the guilty lock seems to be gone
        # See: http://mina.naguib.ca/blog/2010/11/22/postgresql-foreign-key-deadlocks.html
        puts "*" * 80
        puts 'Deadlocked in before!'
        DatabaseCleaner.start
      end
    end
    after do
      begin
        DatabaseCleaner.clean
      rescue ActiveRecord::StatementInvalid
        # Due to a PostgreSQL lock on referenced tables, ActiveRecord throws an exception occasionally
        # So, catch the exception and try to clean again. By this time the guilty lock seems to be gone
        # See: http://mina.naguib.ca/blog/2010/11/22/postgresql-foreign-key-deadlocks.html
        puts "*" * 80
        puts 'Deadlocked in after!'
        DatabaseCleaner.clean
      end
    end
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end
end
