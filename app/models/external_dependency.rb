class ExternalDependency

  def self.get_or_fetch(name, threshold=30)
    name.downcase!
    Rails.cache.fetch(name, :expires_in => 30.seconds) { eval("#{name}_status") }
  end

  def self.fetch_status(name)
    name.downcase!
    status = eval("#{name}_status")
    Rails.cache.write(name, status, :expires_in => 30.seconds)
    status
  end

  private

  def self.retrieve_nice_api_status url
    begin
      content = UrlRetriever.new(url).retrieve_content
    rescue
      content = { 'status' => 'unreachable' }.to_json
    end
    content
  end

  def self.heroku_status
    retrieve_nice_api_status 'https://status.heroku.com/api/v3/current-status'
  end

  def self.github_status
    retrieve_nice_api_status 'https://status.github.com/api/status.json'
  end

  def self.rubygems_status
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
    rescue Exception => e
      output[:status] = 'unreachable'
    end

    output.to_json
  end

end

