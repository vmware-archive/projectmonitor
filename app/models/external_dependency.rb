class ExternalDependency < ActiveRecord::Base

  def self.get_or_fetch_recent_status(name)
    service_status = recent_status name
    service_status ||= fetch_status name
  end

  def self.recent_status(name)
    ExternalDependency.where(name: name).order('created_at').last
  end

  def self.fetch_status(name)
    service = new(:name => name)
    service.get_status
    service.save
    service
  end

  def get_status
    case name
      when 'HEROKU'   then heroku_status
      when 'GITHUB'   then github_status
      when 'RUBYGEMS' then rubygems_status
    end
  end

  private

  def retrieve_nice_api_status url
    begin
      content = UrlRetriever.retrieve_content_at url
    rescue
      content = { 'status' => 'unreachable' }
    end
    self.status = content
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
      doc = Nokogiri::HTML(UrlRetriever.retrieve_content_at('http://status.rubygems.org/'))
      page_status = doc.css('.services td.status span')
      self.raw_response = page_status.to_s

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
    rescue
      output[:status] = 'unreachable'
    end

    self.status = output.to_json
  end

end

