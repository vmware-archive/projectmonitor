class TrackerPayloadParser
  require 'json'

  attr_reader :current_velocity, :last_ten_velocities, :iteration_story_state_counts

  def initialize(project_payload, current_iteration_payload, iterations_payload)
    @current_velocity = parse_current_velocity(project_payload)
    @last_ten_velocities = (parse_iterations(iterations_payload) + [parse_current_iteration(current_iteration_payload)]).reverse
    @iteration_story_state_counts = parse_current_iteration_story_state_counts(current_iteration_payload)
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

  def parse_current_iteration_story_state_counts(current_iteration_payload)
    current_iteration_document = Nokogiri::XML.parse(current_iteration_payload)
    story_counts = []

    unstarted_stories = current_iteration_document.xpath(".//current_state[text() = 'unstarted']/parent::story")
    unstarted_iteration_points = unstarted_stories.xpath(XPath.descendant(:estimate).to_s).map(&:text).map(&:to_i).find_all{ |i| i > 0 }.sum
    story_counts << {"label" => "unstarted", "value" => unstarted_iteration_points}

    started_stories = current_iteration_document.xpath(".//current_state[text() = 'started']/parent::story")
    started_iteration_points = started_stories.xpath(XPath.descendant(:estimate).to_s).map(&:text).map(&:to_i).sum
    story_counts << {"label" => "started", "value" => started_iteration_points}

    finished_stories = current_iteration_document.xpath(".//current_state[text() = 'finished']/parent::story")
    finished_iteration_points = finished_stories.xpath(XPath.descendant(:estimate).to_s).map(&:text).map(&:to_i).sum
    story_counts << {"label" => "finished", "value" => finished_iteration_points}

    delivered_stories = current_iteration_document.xpath(".//current_state[text() = 'delivered']/parent::story")
    delivered_iteration_points = delivered_stories.xpath(XPath.descendant(:estimate).to_s).map(&:text).map(&:to_i).sum
    story_counts << {"label" => "delivered", "value" => delivered_iteration_points}

    accepted_stories = current_iteration_document.xpath(".//current_state[text() = 'accepted']/parent::story")
    accepted_iteration_points = accepted_stories.xpath(XPath.descendant(:estimate).to_s).map(&:text).map(&:to_i).sum
    story_counts << {"label" => "accepted", "value" => accepted_iteration_points}

    rejected_stories = current_iteration_document.xpath(".//current_state[text() = 'rejected']/parent::story")
    rejected_iteration_points = rejected_stories.xpath(XPath.descendant(:estimate).to_s).map(&:text).map(&:to_i).sum
    story_counts << {"label" => "rejected", "value" => rejected_iteration_points}

    story_counts
  end
end
