require 'spec_helper'

describe ExternalDependency do

  context 'class functions' do
    context 'external dependency requests' do
      context 'no external dependency statuses exist' do
        it 'creates a new external dependency status' do
          ExternalDependency.fetch_status('RUBYGEMS')
          ExternalDependency.where(name: 'RUBYGEMS').count.should == 1
        end
      end

      let(:dependency) { ExternalDependency.create name: 'RUBYGEMS' }

      context 'external status exists where created_at > x seconds ago' do
        it 'fetches status from external dependency' do
          dependency.created_at = 1.minute.ago
          dependency.save

          ExternalDependency.get_or_fetch_recent_status('RUBYGEMS')
          ExternalDependency.where(name: 'RUBYGEMS').count.should == 2
        end
      end

      context 'external status exists where create_at <= x seconds ago' do
        it 'fetches status from the database' do
          dependency.created_at = 25.seconds.ago
          dependency.save

          ExternalDependency.get_or_fetch_recent_status('RUBYGEMS')
          ExternalDependency.where(name: 'RUBYGEMS').count.should == 1
        end
      end
    end
  end

  context 'rubygems status' do
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

  context 'github status' do
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

  context 'heroku status' do
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
