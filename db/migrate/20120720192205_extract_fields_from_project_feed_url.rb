class ExtractFieldsFromProjectFeedUrl < ActiveRecord::Migration
  Project = Class.new ActiveRecord::Base
  Project.store_full_sti_class = false
  TravisProject = Class.new Project
  JenkinsProject = Class.new Project
  CruiseControlProject = Class.new Project
  TeamCityProject = Class.new Project
  TeamCityRestProject = Class.new Project

  def up
    transaction do
      change_table :projects do |t|
        # Cruise Control
        t.column :cruise_control_rss_feed_url, :string

        # Jenkins
        t.column :jenkins_base_url, :string
        t.column :jenkins_build_name, :string

        # Team City
        t.column :team_city_base_url, :string
        t.column :team_city_build_id, :string

        # Team City Rest/Chained
        t.column :team_city_rest_base_url, :string
        t.column :team_city_rest_build_type_id, :string

        # Travis
        t.column :travis_github_account, :string
        t.column :travis_repository, :string
      end

      TravisProject.find_each do |project|
        matches = project.feed_url.match %r{^https?://travis-ci.org/([\w-]*)/([\w-]*)/builds\.json$}
        project.update_attributes!(:travis_github_account => matches[1], :travis_repository => matches[2])
      end

      JenkinsProject.find_each do |project|
        matches = project.feed_url.match %r{(https?://.*)/job/(.*)/rssAll$}
        project.update_attributes!(:jenkins_base_url => matches[1], :jenkins_build_name => matches[2])
      end

      CruiseControlProject.find_each do |project|
        project.update_attributes!(:cruise_control_rss_feed_url => project.feed_url)
      end

      TeamCityProject.find_each do |project|
        matches = project.feed_url.match %r{https?://(.*)/guestAuth/cradiator\.html\?buildTypeId=(.*)$}
        project.update_attributes!(:team_city_base_url => matches[1], :team_city_build_id => matches[2])
      end

      [TeamCityRestProject, TeamCityChainedProject].each do |model|
        model.find_each do |project|
          matches = project.feed_url.match %r{http://(.*)/app/rest/builds\?locator=running:all,buildType:\(id:(bt\d*)\)}
          project.update_attributes!(:team_city_rest_base_url => matches[1], :team_city_rest_build_type_id => matches[2])
        end
      end

      rename_column :projects, :feed_url, :deprecated_feed_url
    end
  end

  def down
    change_table :projects do |t|
      t.remove :travis_github_account
      t.remove :travis_repository
      t.remove :jenkins_base_url
      t.remove :jenkins_build_name
      t.remove :cruise_control_rss_feed_url
      t.remove :team_city_base_url
      t.remove :team_city_build_id
      t.remove :team_city_rest_base_url
      t.remove :team_city_rest_build_type_id
    end

    rename_column :projects, :deprecated_feed_url, :feed_url
  end
end
