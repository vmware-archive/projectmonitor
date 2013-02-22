require 'vcr'

VCR.configure do |c|
  c.ignore_hosts = '127.0.0.1', 'localhost'
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
end
