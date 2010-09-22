if ENV['IS_CI_BOX']
  unless system('bundle check')
    puts "IS_CI_BOX is set, running `bundle install`..."
    system('bundle install') || raise("'bundle install' command failed. Install bundler with `gem install bundler`.")
  end
end

begin
  # Sets up the preresolved locked set of gems on the load path.
  require File.expand_path('../../.bundle/environment', __FILE__)
rescue LoadError
  # Fallback on doing the resolve at runtime and then setting up the load path.
  begin
    require "rubygems"
    require "bundler"
  rescue LoadError
    raise "Could not load the bundler gem. Install it with `gem install bundler`."
  end
  
  if Gem::Version.new(Bundler::VERSION) <= Gem::Version.new("0.9.24")
    raise RuntimeError, "Your bundler version is too old.  Run `gem install bundler` to upgrade."
  end
  
  begin
    # Set up load paths for all bundled gems
    ENV["BUNDLE_GEMFILE"] = File.expand_path("Gemfile", RAILS_ROOT)
    Bundler.setup
  rescue Bundler::GemNotFound
    raise RuntimeError, "Bundler couldn't find some gems.  Did you run `bundle install`?  " +
      "If this is a CI box, the IS_CI_BOX env var should be set to automatically run `bundle install` (currently it #{ENV['IS_CI_BOX'] ? 'IS' : 'IS NOT'} set)"
  end
end
