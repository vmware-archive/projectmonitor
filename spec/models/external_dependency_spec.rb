require 'spec_helper'

describe ExternalDependency do

  describe 'rubygems status' do
    it 'initialized an up status' do
      UrlRetriever.stub(:retrieve_content_at) {'<table class="services"><tbody><tr><td class="status"><span class="status status-up"></span></td></tr></tbody></table>' }

      dependency = ExternalDependency.new name: 'RUBYGEMS'
      dependency.get_status
      dependency.name.should == 'RUBYGEMS'
      dependency.raw_response.should == '<span class="status status-up"></span>'
      dependency.status.should == "{\"status\":\"good\"}"
    end

    it 'initialized a down status' do
      UrlRetriever.stub(:retrieve_content_at) {'<table class="services"><tbody><tr><td class="status"><span class="status status-down"></span></td></tr></tbody></table>' }

      dependency = ExternalDependency.new name: 'RUBYGEMS'
      dependency.get_status
      dependency.name.should == 'RUBYGEMS'
      dependency.status.should == "{\"status\":\"bad\"}"
    end

    it 'initialized an unreachable status when it recieved no response' do
      UrlRetriever.stub(:retrieve_content_at) { raise 'error' }

      dependency = ExternalDependency.new name: 'RUBYGEMS'
      dependency.get_status
      dependency.name.should == 'RUBYGEMS'
      dependency.status.should == "{\"status\":\"unreachable\"}"
    end
  end

  describe 'github status' do
    it 'initialized an up status' do
      UrlRetriever.stub(:retrieve_content_at) {'{"status":"good","last_updated":"2013-01-15T20:03:16Z"}'}

      dependency = ExternalDependency.new name: 'GITHUB'
      dependency.get_status
      dependency.name.should == 'GITHUB'
      dependency.status.should == '{"status":"good","last_updated":"2013-01-15T20:03:16Z"}'
    end

    it 'initialized a down status' do
      UrlRetriever.stub(:retrieve_content_at) {'down'}

      dependency = ExternalDependency.new name: 'GITHUB'
      dependency.get_status
      dependency.name.should == 'GITHUB'
      dependency.status.should == 'down'
    end

    it 'initialized a unreachable status' do
      UrlRetriever.stub(:retrieve_content_at) { raise 'error' }

      dependency = ExternalDependency.new name: 'GITHUB'
      dependency.get_status
      dependency.name.should == 'GITHUB'
      dependency.status.should == {'status' => 'unreachable'}
    end
  end

  describe 'heroku status' do
    it 'initalized an up status' do
      UrlRetriever.stub(:retrieve_content_at) {'up'}

      dependency = ExternalDependency.new name: 'HEROKU'
      dependency.get_status
      dependency.name.should == 'HEROKU'
      dependency.status.should == 'up'
    end

    it 'initalized a down status' do
      UrlRetriever.stub(:retrieve_content_at) { 'down' }

      dependency = ExternalDependency.new name: 'HEROKU'
      dependency.get_status
      dependency.name.should == 'HEROKU'
      dependency.status.should == 'down'
    end

    it 'initalized an unreachable status when it receives no response' do
      UrlRetriever.stub(:retrieve_content_at) { raise 'error' }

      dependency = ExternalDependency.new name: 'HEROKU'
      dependency.get_status
      dependency.name.should == 'HEROKU'
      dependency.status.should == {'status' => 'unreachable'}
    end
  end

end
