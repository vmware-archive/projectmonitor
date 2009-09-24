############# GemInstaller preinitializer - see http://geminstaller.rubyforge.org

require "rubygems"
require "geminstaller"

# The 'autogem' method will automatically add all gems in the GemInstaller config to your load path, using the 'gem'
# or 'require_gem' command.  Note that only the *first* version of any given gem will be loaded.
GemInstaller.autogem("--exceptions --config #{File.expand_path(RAILS_ROOT)}/config/geminstaller.yml")


