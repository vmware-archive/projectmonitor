class ExternalDependency < ActiveRecord::Base

  def self.get_or_fetch_recent_status(name, threshold=30)
    last_status = recent_status name
    last_status ||= fetch_status name
    last_status.created_at < threshold.seconds.ago ? fetch_status(name) : last_status
  end

  def self.recent_status(name)
    where(name: name).order('created_at').last
  end

  def self.fetch_status(name)
    delete_most_recent(name)

    service = new(:name => name)
    service.get_status
    service.save
    service
  end

  def get_status
    eval("#{name.downcase}_status")
  end

  private
  def self.delete_most_recent(name)
    most_recent = recent_status(name)
    most_recent.destroy unless most_recent.nil?
  end

  def retrieve_nice_api_status url
    begin
      content = UrlRetriever.new(url).retrieve_content
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
      doc = Nokogiri::HTML(UrlRetriever.new('http://status.rubygems.org/').retrieve_content)
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

