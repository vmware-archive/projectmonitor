class TrackerPayloadParser
  require 'json'

  attr_reader :current_velocity, :last_ten_velocities, :iteration_story_state_counts

  STORY_STATES = %w(unstarted started finished delivered accepted rejected)

  def initialize(project_payload, current_iteration_payload, iterations_payload)
    @current_velocity = parse_current_velocity(project_payload)
    @last_ten_velocities = (parse_iterations(iterations_payload) + [parse_current_iteration(current_iteration_payload)]).reverse
    @iteration_story_state_counts = parse_current_iteration_story_state_counts(current_iteration_payload)
  end

private

  def parse_current_velocity(project_payload)
    project_document = Nokogiri::XML.parse(project_payload)
    (project_document.xpath('.//current_velocity').first.try(:text) || 0).to_i
  end

  def parse_iterations(iterations_payload)
    iterations_document = Nokogiri::XML.parse(iterations_payload)
    iterations = iterations_document.xpath('.//iteration')
    iterations.to_a.last(9).map {|iteration| sum_story_points(iteration)}
  end

  def parse_current_iteration(current_iteration_payload)
    current_iteration_document = Nokogiri::XML.parse(current_iteration_payload)
    parse_stories(current_iteration_document, "accepted")
  end

  def parse_current_iteration_story_state_counts(current_iteration_payload)
    current_iteration_document = Nokogiri::XML.parse(current_iteration_payload)
    story_counts = []

    STORY_STATES.each do |state|
      story_counts << {"label" => "#{state}", "value" => parse_stories(current_iteration_document, state)}
    end

    story_counts
  end

  def parse_stories(iteration_document, state)
    stories = iteration_document.xpath(".//current_state[text() = '#{state}']/parent::story")
    points = sum_story_points(stories)
  end

  def sum_story_points(stories)
    stories.xpath('.//estimate').map(&:text).map(&:to_i).select { |x| x >= 0 }.sum
  end
end
