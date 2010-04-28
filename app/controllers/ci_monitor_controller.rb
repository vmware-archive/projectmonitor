class CiMonitorController < ApplicationController
  def show
    @projects = Project.with_options(:conditions => {:enabled => true}, :order => 'name', :include => :statuses) do |sorted|
      params[:tags] ? sorted.find_tagged_with(params[:tags]) : sorted.find(:all)
    end

    @messages = Message.all
  end
end
