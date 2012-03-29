class DashboardsController < ApplicationController
  def show
    if params[:tags]
      aggregate_projects = AggregateProject.find_tagged_with(params[:tags], :conditions => {:enabled => true}, :include => {:projects => :latest_status})
      aggregate_project_ids = aggregate_projects.map(&:id)
      projects = Project.all(:include => :latest_status).select do |project|
        ((params[:tags] && (project.tag_list & Array(params[:tags])) != []) || !params[:tags].present?) &&
          project.enabled? &&
          !(aggregate_project_ids.include?(project.aggregate_project_id))
      end

      @projects = (projects + aggregate_projects).sort_by(&:name)

      @messages = Message.active.find_tagged_with(params[:tags])
      @twitter_searches = TwitterSearch.find_tagged_with(params[:tags])
    else
      @projects = Project.standalone.includes(:latest_status) + AggregateProject.with_projects.includes(:projects => :latest_status)
      @projects = @projects.sort_by(&:name)

      @messages = Message.active
      @twitter_searches = TwitterSearch.all
    end
  end
end
