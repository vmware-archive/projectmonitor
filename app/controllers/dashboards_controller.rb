class DashboardsController < ApplicationController
  def show
    if params[:tags]
      aggregate_projects = AggregateProject.find_tagged_with(params[:tags], :conditions => {:enabled => true}, :include => {:projects => :latest_status})
      aggregate_project_ids = aggregate_projects.map(&:id)
      projects = Project.where("aggregate_project_id NOT IN (?) OR aggregate_project_id IS NULL", aggregate_project_ids)\
        .find_tagged_with(params[:tags], :conditions => {:enabled => true}, :include => :latest_status)

      @projects = (projects + aggregate_projects).sort_by(&:name)

      @messages = Message.active.find_tagged_with(params[:tags])
      @twitter_searches = TwitterSearch.find_tagged_with(params[:tags])
    else
      @projects = Project.standalone.includes(:latest_status) + AggregateProject.with_projects.includes(:projects => :latest_status)
      @projects = @projects.sort_by(&:name)

      @messages = Message.active
      @twitter_searches = TwitterSearch.all
    end

    skin = params[:skin]
    render :layout => "layouts/skins/#{skin}" if skin_exists?(skin)
  end

  private

  def skin_exists?(skin)
    File.exists?(Rails.root.join("app", "views", "layouts", "skins", "#{skin}.html.erb"))
  end
end
