require 'vcr'

VCR.configure do |c|
  c.ignore_localhost = true
  c.ignore_hosts 'api.imgur.com'
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :fakeweb
  c.configure_rspec_metadata!
end
