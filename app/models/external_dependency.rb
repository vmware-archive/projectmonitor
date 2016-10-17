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
        net_http_builder = NetHttpBuilder.new
        response_body = SynchronousHttpRequester.new(net_http_builder).retrieve_content('https://pclby00q90vc.statuspage.io/api/v2/status.json')
        output[:status] = extract_rubygems_status(response_body)
      rescue StandardError => e
        output[:status] = 'unreachable'
      end

      output.to_json
    end

    private

    def retrieve_nice_api_status url
      begin
        net_http_builder = NetHttpBuilder.new
        content = SynchronousHttpRequester.new(net_http_builder).retrieve_content(url)
      rescue
        content = { 'status' => 'unreachable' }.to_json
      end
      content
    end

    def refresh_status(name)
      send("#{name}_status")
    end

    def extract_rubygems_status(response_body)
      JSON.parse(response_body).fetch('status', {}).fetch('indicator', 'unreachable')
    end
  end
end
