class DashboardsController < ApplicationController
  def show
    if params[:tags]
      @projects = Project.find_tagged_with(params[:tags], :conditions => {:enabled => true}, :order => 'name', :include => :statuses)
      @projects += AggregateProject.find_tagged_with(params[:tags], :conditions => {:enabled => true}, :order => 'name')
    else
      @projects = Project.standalone
      @projects += AggregateProject.with_projects.flatten
    end

    @messages = Message.all
  end
end
