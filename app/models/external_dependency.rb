class ExternalDependency

  class << self
    def get_or_fetch(name, threshold=30)
      name.downcase!
      Rails.cache.fetch(name, expires_in: threshold.seconds) { refresh_status(name) }
    end

    def fetch_status(name)
      name.downcase!
      status = refresh_status(name)
      Rails.cache.write(name, status, expires_in: 30.seconds)
      status
    end

    def heroku_status
      retrieve_nice_api_status 'https://status.heroku.com/api/v3/current-status'
    end

    def github_status
      retrieve_nice_api_status 'https://status.github.com/api/status.json'
    end

    def rubygems_status
      output = {}

      begin
        doc = Nokogiri::HTML(UrlRetriever.new('http://status.rubygems.org/').retrieve_content)
        page_status = doc.css('.services td.status span')

        if page_status.any?
          if page_status.last.attributes["class"].value.split(' ').include?("status-up")
            output[:status] = "good"
          else
            output[:status] = "bad"
          end
        else
          output[:status] = 'page broken'
        end

      rescue Nokogiri::SyntaxError => e
        output[:status] = 'page broken'
      rescue StandardError => e
        output[:status] = 'unreachable'
      end

      output.to_json
    end

    private

    def retrieve_nice_api_status url
      begin
        content = UrlRetriever.new(url).retrieve_content
      rescue
        content = { 'status' => 'unreachable' }.to_json
      end
      content
    end

    def refresh_status(name)
      send("#{name}_status")
    end
  end
end
