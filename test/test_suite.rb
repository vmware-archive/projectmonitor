require 'test/unit'

Dir.chdir("test")
@@test_files = Dir.glob("**/*_test.rb")
Dir.chdir("..")
@@test_files.each {|x| require "test/" + x unless x.include?("selenium")}
