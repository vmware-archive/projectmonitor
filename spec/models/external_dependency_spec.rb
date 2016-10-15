require 'spec_helper'

describe ExternalDependency, :type => :model do

  context 'class functions', vcr: {re_record_interval: 6.months} do
    context 'external dependency requests' do
      context 'no external dependency statuses exist' do
        it 'creates a new external dependency status' do
          allow(ExternalDependency).to receive(:rubygems_status) { 'good' }
          ExternalDependency.fetch_status('RUBYGEMS')
          expect(Rails.cache.read(:rubygems)).to eq('good')
        end
      end

      context 'external status exists where created_at >= x seconds ago' do
        it 'fetches status from external dependency' do
          allow(ExternalDependency).to receive(:rubygems_status) { 'good' }
          Timecop.travel(35.seconds.ago)
          ExternalDependency.fetch_status('RUBYGEMS')
          Timecop.travel(35.seconds.from_now)

          expect(ExternalDependency).to receive(:rubygems_status)
          ExternalDependency.get_or_fetch('RUBYGEMS')
          expect(Rails.cache.read(:rubygems)).to eq('good')
        end
      end

      context 'external status exists where create_at < x seconds ago' do
        it 'fetches status from the database' do
          allow(ExternalDependency).to receive(:rubygems_status) { 'good' }
          Timecop.travel(29.seconds.ago)
          ExternalDependency.fetch_status('RUBYGEMS')
          Timecop.travel(29.seconds.from_now)

          expect(ExternalDependency).not_to receive(:rubygems_status)
          ExternalDependency.get_or_fetch('RUBYGEMS')
          expect(Rails.cache.read(:rubygems)).to eq('good')
        end
      end
    end
  end

  context 'rubygems status' do
    it 'initialized an none status' do
      allow_any_instance_of(SynchronousHttpRequester).to receive(:retrieve_content) {"{\"status\":{\"indicator\":\"none\",\"description\":\"All Systems Operational\"}}" }

      expect(ExternalDependency.rubygems_status).to eq("{\"status\":\"none\"}")
    end

    it 'initialized a minor status' do
      allow_any_instance_of(SynchronousHttpRequester).to receive(:retrieve_content) {"{\"status\":{\"indicator\":\"minor\",\"description\":\"Some minor issues\"}}" }

      expect(ExternalDependency.rubygems_status).to eq("{\"status\":\"minor\"}")
    end

    it 'initialized a major status' do
      allow_any_instance_of(SynchronousHttpRequester).to receive(:retrieve_content) {"{\"status\":{\"indicator\":\"major\",\"description\":\"Some major issues\"}}" }

      expect(ExternalDependency.rubygems_status).to eq("{\"status\":\"major\"}")
    end

    it 'initialized a critical status' do
      allow_any_instance_of(SynchronousHttpRequester).to receive(:retrieve_content) {"{\"status\":{\"indicator\":\"critical\",\"description\":\"Some critical issues\"}}" }

      expect(ExternalDependency.rubygems_status).to eq("{\"status\":\"critical\"}")
    end

    it 'initialized an unreachable status when it recieved an unparsable response' do
      allow_any_instance_of(SynchronousHttpRequester).to receive(:retrieve_content) { "{\"foo\":\"bar\"}" }

      expect(ExternalDependency.rubygems_status).to eq("{\"status\":\"unreachable\"}")
    end

    it 'initialized an unreachable status when it recieved no response' do
      allow_any_instance_of(SynchronousHttpRequester).to receive(:retrieve_content) { raise 'error' }

      expect(ExternalDependency.rubygems_status).to eq("{\"status\":\"unreachable\"}")
    end
  end

  context 'github status' do
    it 'initialized an up status' do
      allow_any_instance_of(SynchronousHttpRequester).to receive(:retrieve_content) {'{"status":"good","last_updated":"2013-01-15T20:03:16Z"}'}

      expect(ExternalDependency.github_status).to eq("{\"status\":\"good\",\"last_updated\":\"2013-01-15T20:03:16Z\"}")
    end

    it 'initialized a down status' do
      allow_any_instance_of(SynchronousHttpRequester).to receive(:retrieve_content) {'{"status":"down","last_updated":"2013-01-15T20:03:16Z"}'}

      expect(ExternalDependency.github_status).to eq("{\"status\":\"down\",\"last_updated\":\"2013-01-15T20:03:16Z\"}")
    end

    it 'initialized a unreachable status' do
      allow_any_instance_of(SynchronousHttpRequester).to receive(:retrieve_content) { raise 'error' }

      expect(ExternalDependency.github_status).to eq("{\"status\":\"unreachable\"}")
    end
  end

  context 'heroku status' do
    it 'initalized an up status' do
      allow_any_instance_of(SynchronousHttpRequester).to receive(:retrieve_content) { '{"status":{"Production":"green","Development":"green"},"issues":[]}' }

      expect(JSON.parse(ExternalDependency.heroku_status)['status']['Production']).to eq("green")
    end

    it 'initalized a down status' do
      allow_any_instance_of(SynchronousHttpRequester).to receive(:retrieve_content) { '{"status":{"Production":"red","Development":"red"},"issues":[]}' }

      expect(JSON.parse(ExternalDependency.heroku_status)['status']['Production']).not_to eq("green")
    end

    it 'initalized an unreachable status when it receives no response' do
      allow_any_instance_of(SynchronousHttpRequester).to receive(:retrieve_content) { raise 'error' }

      expect(JSON.parse(ExternalDependency.heroku_status)['status']).to eq("unreachable")
    end
  end

end
