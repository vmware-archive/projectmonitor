class DashboardsController < ApplicationController
  def show
    if params[:tags]
      aggregate_projects = AggregateProject.find_tagged_with(params[:tags], :conditions => {:enabled => true})
      projects = Project.find_tagged_with(params[:tags], :conditions => {:enabled => true}, :include => :statuses)
      projects.reject! {|project| aggregate_projects.map(&:id).include?(project.aggregate_project_id)}
      @projects = (projects + aggregate_projects).sort_by(&:name)

      @messages = Message.active.find_tagged_with(params[:tags])
      @twitter_searches = TwitterSearch.find_tagged_with(params[:tags])
    else
      @projects = Project.standalone + AggregateProject.with_projects
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
