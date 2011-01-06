class DashboardsController < ApplicationController
  def show
    if params[:tags]
      aggregate_projects = AggregateProject.find_tagged_with(params[:tags], :conditions => {:enabled => true}, :order => 'name')
      projects = Project.find_tagged_with(params[:tags], :conditions => {:enabled => true}, :order => 'name', :include => :statuses)
      @projects = projects.reject {|project| aggregate_projects.include?(project.aggregate_project)} + aggregate_projects
    else
      @projects = Project.standalone
      @projects += AggregateProject.with_projects.flatten
    end

    @messages = Message.all
  end
end
