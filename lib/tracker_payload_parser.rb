class TrackerPayloadParser

  attr_reader :current_velocity, :last_ten_velocities

  def initialize(project_payload, current_iteration_payload, iterations_payload)
    @current_velocity = parse_current_velocity(project_payload)
    @last_ten_velocities = (parse_iterations(iterations_payload) + [parse_current_iteration(current_iteration_payload)]).reverse
  end

private

  def parse_current_velocity(project_payload)
    project_document = Nokogiri::XML.parse(project_payload)
    (project_document.xpath(XPath.descendant(:current_velocity).to_s).first.try(:text) || 0).to_i
  end

  def parse_iterations(iterations_payload)
    iterations_document = Nokogiri::XML.parse(iterations_payload)
    iterations = iterations_document.xpath(XPath.descendant(:iteration).to_s)
    iterations.to_a.last(9).map do |iteration|
      estimates = iteration.xpath(XPath.descendant(:estimate).to_s)
      estimates.map(&:text).map(&:to_i).sum
    end
  end

  def parse_current_iteration(current_iteration_payload)
    current_iteration_document = Nokogiri::XML.parse(current_iteration_payload)
    accepted_stories = current_iteration_document.xpath(".//current_state[text() = 'accepted']/parent::story")# XPath.descendant(:story).to_s)
    accepted_stories.xpath(XPath.descendant(:estimate).to_s).map(&:text).map(&:to_i).sum
  end

end
