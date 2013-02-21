require 'spec_helper'

describe ExternalDependency do

  context 'class functions', vcr: {re_record_interval: 6.months} do
    context 'external dependency requests' do
      context 'no external dependency statuses exist' do
        it 'creates a new external dependency status' do
          ExternalDependency.stub(:rubygems_status) { 'good' }
          ExternalDependency.fetch_status('RUBYGEMS')
          Rails.cache.read(:rubygems).should == 'good'
        end
      end

      context 'external status exists where created_at >= x seconds ago' do
        it 'fetches status from external dependency' do
          ExternalDependency.stub(:rubygems_status) { 'good' }
          Timecop.travel(35.seconds.ago)
          ExternalDependency.fetch_status('RUBYGEMS')
          Timecop.travel(35.seconds.from_now)

          ExternalDependency.should_receive(:rubygems_status)
          ExternalDependency.get_or_fetch('RUBYGEMS')
          Rails.cache.read(:rubygems).should == 'good'
        end
      end

      context 'external status exists where create_at < x seconds ago' do
        it 'fetches status from the database' do
          ExternalDependency.stub(:rubygems_status) { 'good' }
          Timecop.travel(29.seconds.ago)
          ExternalDependency.fetch_status('RUBYGEMS')
          Timecop.travel(29.seconds.from_now)

          ExternalDependency.should_not_receive(:rubygems_status)
          ExternalDependency.get_or_fetch('RUBYGEMS')
          Rails.cache.read(:rubygems).should == 'good'
        end
      end
    end
  end

  context 'rubygems status' do
    it 'initialized an up status' do
      UrlRetriever.any_instance.stub(:retrieve_content) {'<table class="services"><tbody><tr><td class="status"><span class="status status-up"></span></td></tr></tbody></table>' }

      ExternalDependency.rubygems_status.should == "{\"status\":\"good\"}"
    end

    it 'initialized a down status' do
      UrlRetriever.any_instance.stub(:retrieve_content) {'<table class="services"><tbody><tr><td class="status"><span class="status status-down"></span></td></tr></tbody></table>' }

      ExternalDependency.rubygems_status.should == "{\"status\":\"bad\"}"
    end

    it 'initialized an unreachable status when it recieved no response' do
      UrlRetriever.any_instance.stub(:retrieve_content) { raise 'error' }

      ExternalDependency.rubygems_status.should == "{\"status\":\"unreachable\"}"
    end
  end

  context 'github status' do
    it 'initialized an up status' do
      UrlRetriever.any_instance.stub(:retrieve_content) {'{"status":"good","last_updated":"2013-01-15T20:03:16Z"}'}

      ExternalDependency.github_status.should == "{\"status\":\"good\",\"last_updated\":\"2013-01-15T20:03:16Z\"}"
    end

    it 'initialized a down status' do
      UrlRetriever.any_instance.stub(:retrieve_content) {'{"status":"down","last_updated":"2013-01-15T20:03:16Z"}'}

      ExternalDependency.github_status.should == "{\"status\":\"down\",\"last_updated\":\"2013-01-15T20:03:16Z\"}"
    end

    it 'initialized a unreachable status' do
      UrlRetriever.any_instance.stub(:retrieve_content) { raise 'error' }

      ExternalDependency.github_status.should == "{\"status\":\"unreachable\"}"
    end
  end

  context 'heroku status' do
    it 'initalized an up status' do
      UrlRetriever.any_instance.stub(:retrieve_content) { '{"status":{"Production":"green","Development":"green"},"issues":[]}' }

      JSON.parse(ExternalDependency.heroku_status)['status']['Production'].should == "green"
    end

    it 'initalized a down status' do
      UrlRetriever.any_instance.stub(:retrieve_content) { '{"status":{"Production":"red","Development":"red"},"issues":[]}' }

      JSON.parse(ExternalDependency.heroku_status)['status']['Production'].should_not == "green"
    end

    it 'initalized an unreachable status when it receives no response' do
      UrlRetriever.any_instance.stub(:retrieve_content) { raise 'error' }

      JSON.parse(ExternalDependency.heroku_status)['status'].should == "unreachable"
    end
  end

end
