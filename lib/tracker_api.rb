require 'open-uri'
require 'active_support/all'

class TrackerApi
  def initialize(token)
    @token = token
  end

  def fetch_current_iteration(project_id)
    url = "http://www.pivotaltracker.com/services/v3/projects/#{project_id}/iterations/current"

    Hash.from_xml(fetch_xml_response(url))["iterations"].first
  end


  private

  def fetch_xml_response(url)
    Kernel.open(url, { "X-TrackerToken" => @token})
          .read
  end
end
