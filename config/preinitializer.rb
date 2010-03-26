DEPENDENCY_TOOL = ENV['dependency_tool'] ? ENV['dependency_tool'].to_sym : :bundler

if DEPENDENCY_TOOL == :geminstaller
  require 'rubygems'
  require 'geminstaller'
  require 'geminstaller_rails_preinitializer'
  # This is to automatically install dependencies on CI boxes
  GemInstaller.install(['--sudo'])  
elsif DEPENDENCY_TOOL == :bundler
  # This is to automatically install dependencies on CI boxes
  # Requires that you have bundler already installed
  system('bundle install') || raise("'bundle install' command failed.  gem install bundler if it is not installed")

  begin
    # Sets up the preresolved locked set of gems on the load path.
    require File.expand_path('../../.bundle/environment', __FILE__)
  rescue LoadError
    # Fallback on doing the resolve at runtime and then setting up the load path.
    require "rubygems"
    require "bundler"
    if Gem::Version.new(Bundler::VERSION) <= Gem::Version.new("0.9.5")
      raise RuntimeError, "Bundler incompatible.\n" +
        "Your bundler version is incompatible with Rails 2.3 and an unlocked bundle.\n" +
        "Run `gem install bundler` to upgrade or `bundle lock` to lock."
    else
      Bundler.setup
    end
  end
end
