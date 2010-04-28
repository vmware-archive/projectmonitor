require File.dirname(__FILE__) + '/../spec_helper'

class SvnSheller
  def retrieve
    File.read('test/fixtures/svn_log_examples/svn.xml')
  end
end

describe CiMonitorController do
  integrate_views

  describe "#show" do
    it "should succeed" do
      get :show
      response.should be_success
    end

    it "should filter by tag" do
      nyc_projects = Project.find_tagged_with('NYC')
      nyc_projects.should_not be_empty

      get :show, :size => 'tiny', :tags => 'NYC'
      assigns(:projects).should contain_exactly(nyc_projects)
    end

    it "should sort the projects by name" do
      sorted_projects = Project.find(:all, :conditions => {:enabled => true}).sort_by(&:name)
      get :show
      assigns(:projects).should == sorted_projects
    end

    it "should not store the most recent request location" do
      session[:location] = nil
      get :show
      session[:location].should be_nil
    end

    it "should display a red spinner for red building projects" do
      get :show
      building_projects = Project.find(:all, :conditions => {:enabled => true, :building => true}).reject(&:green?)
      building_projects.should_not be_empty
      building_projects.each do |project|
        response.should have_tag("div.box[project_id='#{project.id}']") do |box|
          box.should have_tag("img", :src => "build-loader-red.gif")
        end
      end
    end

    it "should display a green spinner for green building projects" do
      get :show
      green_building_projects = Project.find(:all, :conditions => {:enabled => true, :building => true}).select(&:green?)
      green_building_projects.should_not be_empty
      green_building_projects.each do |project|
        response.should have_tag("div.box[project_id='#{project.id}']") do |box|
          box.should have_tag("img", :src => "build-loader-green.gif")
        end
      end
    end

    it "should display a checkmark for green projects not building" do
      get :show
      not_building_projects = Project.find_all_by_enabled(true).reject(&:building?)
      not_building_projects.should_not be_empty
      not_building_projects.each do |project|
        response.should have_tag("div.box[project_id='#{project.id}']") do |box|
          box.should have_tag("img", :src => "checkmark.png")
        end
      end
    end
    
    it "should display an exclamation for red projects not building" do
      get :show
      not_building_projects = Project.find_all_by_enabled(true).reject(&:building?)
      not_building_projects.should_not be_empty
      not_building_projects.each do |project|
        response.should have_tag("div.box[project_id='#{project.id}']") do |box|
          box.should have_tag("img", :src => "exclamation.png")
        end
      end
    end
  end
end