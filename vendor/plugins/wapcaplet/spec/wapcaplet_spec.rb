require "rubygems"

require "activesupport"
require "action_controller"
require "activerecord"
require "spec"
require 'lib/wapcaplet'

class AModel < ActiveRecord::Base
  set_table_name nil
  def self.columns; []; end

  def to_param
    "a-param"
  end
end

class AController < ActionController::Base
  def show
    head :ok
  end
end

class ANestedController < ActionController::Base
  def show
    head :ok
  end
end

ActionController::Routing::Routes.load!
ActionController::Routing::Routes.draw do |map|
  map.resource :a_nested, :path_prefix => "parents/:parent_id/", :controller => 'a_nested', :action => 'show'
end

describe "functional test parameters" do
  include ActionController::TestProcess

  before(:each) do
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @controller = AController.new
  end

  it "should raise an exception if any non-route parameter is not a string" do
    non_strings.each do |not_a_string|
      lambda { get :show, :wibble => not_a_string }.should raise_error(ArgumentError)
    end
  end

  it "should raise an exception if any non-route parameter is not a string, even if it responds to #to_param" do
    lambda { get :show, :wibble => fake_active_record }.should raise_error(ArgumentError)
  end

  it "should work with nested parameters" do
    lambda { get :show, :wibble => { :thing => "a string" } }.should_not raise_error
  end

  it "should raise an exception if a nested HTTP request parameter is not a string" do
    non_strings.each do |not_a_string|
      lambda { get :show, :wibble => { :thing => not_a_string } }.should raise_error(ArgumentError)
    end
  end

  it "should work with array parameters" do
    lambda { get :show, :wibbles => ["one", "two"] }.should_not raise_error
  end

  it "should raise an exception if a member of an array parameter is not a string" do
    non_strings.each do |not_a_string|
      lambda { get :show, :wibbles => ["one", not_a_string] }.should raise_error(ArgumentError)
    end
  end

  it "should not raise an exception for a file upload parameter" do
    file_path = File.join(File.dirname(__FILE__), "files", "foo.jpg")
    lambda { get :show, :wibble_asset => fixture_file_upload(file_path, 'image/jpg') }.should_not raise_error
  end

  it "should allow nils" do
    lambda { get :show, :wibble => nil }.should_not raise_error
  end

  it "should not raise an exception if a session or flash parameter is not a string" do
    non_strings.each do |not_a_string|
      lambda { get :show, {}, { :foozle => not_a_string } }.should_not raise_error
      lambda { get :show, {}, {}, { :foozle => not_a_string } }.should_not raise_error
    end
  end

  context "for a nested route" do
    before(:each) do
      @controller = ANestedController.new
    end

    it "should allow string values for route parameters" do
      lambda { get :show, :parent_id => "parent-param", :wibble => "a_string" }.should_not raise_error
    end

    it "should allow subclasses of ActiveRecord for route parameters" do
      lambda { get :show, :parent_id => fake_active_record, :wibble => "a_string" }.should_not raise_error
    end

    it "should not allow non-ActiveRecord, non-string values for route parameters" do
      non_strings.each do |not_a_string|
        lambda { get :show, :parent_id => not_a_string, :wibble => "a_string" }.should raise_error(ArgumentError)
      end
    end
  end

  private

  def non_strings
    [1, Time.now, 1.0, /hello/, :symbol]
  end

  def fake_active_record
    AModel.new
  end
end
