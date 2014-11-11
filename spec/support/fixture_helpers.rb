def load_fixture(fixture_dir, fixture_file)
  File.read(File.join(RSpec.configuration.fixture_path, fixture_dir, fixture_file))
end
