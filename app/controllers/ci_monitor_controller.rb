class CiMonitorController < ApplicationController
  def show
    if params[:tags]
      @projects = Project.find_tagged_with(params[:tags], :conditions => {:enabled => true}, :order => 'name', :include => :statuses)
    else
      @projects = Project.where(:enabled => true).order(:name)
    end

    @messages = Message.all
  end
end
