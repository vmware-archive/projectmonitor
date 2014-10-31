require 'spec_helper'

feature 'Projects API' do
  let(:user)                  { create(:user, password: 'jeffjeff') }
  let(:red_project)           { Project.find_by(code: 'ALRE') }
  let(:aggregate_project)     { AggregateProject.find_by(name: 'Aggregation') }
  let!(:project_with_tracker) { create(:project_with_tracker_integration, code: "xxxx") }

  background { log_in user, 'jeffjeff' }

  def json_response
    MultiJson.load(page.driver.response.body)
  end

  scenario 'Index API (GET #index)', js: false do
    page.driver.get '/projects.json'

    expect(json_response.size).to eq 11
    expect(json_response.map{|p| p['code'] }).to eq %w(
      ALRE CBGR JPP MANY NBL PIV SOC XUM XXX aggr xxxx
    )

    json_response.first.tap do |project|
      expect(project['id']).to be_a Fixnum
      expect(project['name']).to eq 'Red Currently Building'
      expect(project['enabled']).to be true
      expect(project['building']).to be true
      expect(project['aggregate_project_id']).to be_nil
      expect(project['code']).to eq 'ALRE'
      expect(project['deprecated_location']).to be_nil
      expect(project['tracker_project_id']).to be_nil
      expect(project['current_velocity']).to eq 0
      expect(project['last_ten_velocities']).to eq []
      expect(project['tracker_online']).to be_nil

      # NOTE: URIs don't have to start with 'http' but for us this is true.
      expect(project['cruise_control_rss_feed_url']).to match /^http(s*):\/\//

      expect(project['jenkins_base_url']).to be_nil
      expect(project['jenkins_build_name']).to be_nil
      expect(project['team_city_base_url']).to be_nil
      expect(project['team_city_build_id']).to be_nil
      expect(project['team_city_rest_base_url']).to be_nil
      expect(project['team_city_rest_build_type_id']).to be_nil
      expect(project['travis_github_account']).to be_nil
      expect(project['travis_repository']).to be_nil
      expect(project['online']).to be true
      expect(project['guid']).to be_nil
      expect(project['webhooks_enabled']).to be_nil
      expect(project['tracker_validation_status']).to eq({})
      expect(project['last_refreshed_at']).to be_nil
      expect(project['semaphore_api_url']).to be_nil
      expect(project['parsed_url']).to be_nil
      expect(project['tddium_auth_token']).to be_nil
      expect(project['tddium_project_name']).to be_nil
      expect(project['notification_email']).to be_nil
      expect(project['verify_ssl']).to be true
      expect(project['stories_to_accept_count']).to be_nil
      expect(project['open_stories_count']).to be_nil
      expect(project['build_branch']).to be_nil
      expect(project['iteration_story_state_counts']).to eq({})
      expect(project['creator_id']).to be_nil
      expect(project['circleci_auth_token']).to be_nil
      expect(project['circleci_project_name']).to be_nil
      expect(project['circleci_username']).to be_nil
      expect(project['tag_list']).to eq []
      expect(project['project_id']).to be_a Fixnum
      expect(project['created_at']).to eq red_project.created_at.iso8601(3)
      expect(project['updated_at']).to eq red_project.created_at.iso8601(3)

      project['build'].tap do |build|
        expect(build['id']).to be_a Fixnum
        expect(build['building']).to be true
        expect(build['code']).to eq 'ALRE'
        expect(build['published_at']).to be_a String
        expect(build['status']).to eq 'failure'

        build['statuses'].first.tap do |status|
          expect(status['success']).to be false
          expect(status['url']).to be_nil
        end
      end
    end

    projekt_with_tracker = json_response.find {|project| project['name'] == project_with_tracker.name }

    projekt_with_tracker['tracker'].tap do |tracker|
      expect(tracker['current_velocity']).to eq 15
      expect(tracker['last_ten_velocities']).to eq [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
      expect(tracker['tracker_online']).to be true
      expect(tracker['stories_to_accept_count']).to eq 7
      expect(tracker['open_stories_count']).to eq 16
      expect(tracker['volatility']).to eq 55
      expect(tracker['iteration_story_state_counts']).to eq []
    end

    json_response.find {|p| p['name'] == aggregate_project.name }.tap do |aggregate_projekt|
      expect(aggregate_projekt['id']).to eq aggregate_project.id
      expect(aggregate_projekt['name']).to eq 'Aggregation'
      expect(aggregate_projekt['enabled']).to be true
      expect(aggregate_projekt['created_at']).to eq aggregate_project.created_at.iso8601(3)
      expect(aggregate_projekt['updated_at']).to eq aggregate_project.created_at.iso8601(3)
      expect(aggregate_projekt['code']).to eq 'aggr'
      expect(aggregate_projekt['location']).to be_nil
      expect(aggregate_projekt['tag_list']).to eq []
      expect(aggregate_projekt['aggregate']).to be true
      expect(aggregate_projekt['status']).to eq 'success'
    end
  end
end