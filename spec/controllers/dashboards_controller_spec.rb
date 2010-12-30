require 'spec_helper'

describe DashboardsController do
  render_views

  describe "routes" do
    it "should map /dashboard to #show" do
      {:get => "/dashboard"}.should route_to(:controller => 'dashboards', :action => 'show')
    end
  end

  describe "#show" do
    it "should succeed" do
      get :show
      response.should be_success
    end

    describe "login link" do
      describe "using local password auth" do
        before(:each) do
          AuthConfig.stub(:auth_file_path).and_return(Rails.root.join("spec/fixtures/files/auth-password.yml"))
        end

        it "renders link to /sessions/new" do
          get :show
          response.should be_success
          response.should have_tag(%Q{a[href="#{login_path}"]})
        end

        describe "logged in links" do
          before(:each) do
            log_in(create_user)
          end

          it "renders link to /users/new" do
            get :show
            response.should be_success
            response.should have_tag(%Q{a[href="#{new_user_path}"]})
          end
        end
      end

      describe "using openid auth" do
        before(:each) do
          AuthConfig.stub(:auth_file_path).and_return(Rails.root.join("spec/fixtures/files/auth-openid.yml"))
        end

        it "renders link to /openid/new" do
          get :show
          response.should be_success
          response.should have_tag(%Q{a[href="#{new_openid_path}"]})
        end

        describe "logged in links" do
          before(:each) do
            log_in(create_user)
          end

          it "renders link to /users/new" do
            get :show
            response.should be_success
            response.should_not have_tag(%Q{a[href="#{new_user_path}"]})
          end
        end
      end
    end

    it "should filter by tag" do
      nyc_projects = Project.find_tagged_with('NYC')
      nyc_projects.should_not be_empty

      get :show, :size => 'tiny', :tags => 'NYC'
      assigns(:projects).should =~ nyc_projects
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
      not_building_projects = Project.standalone.reject(&:building?)
      not_building_projects.should_not be_empty
      not_building_projects.each do |project|
        response.should have_tag("div.box[project_id='#{project.id}']") do |box|
          box.should have_tag("img", :src => "checkmark.png")
        end
      end
    end

    it "should display an exclamation for red projects not building" do
      get :show
      not_building_projects = Project.standalone.reject(&:building?)
      not_building_projects.should_not be_empty
      not_building_projects.each do |project|
        response.should have_tag("div.box[project_id='#{project.id}']") do |box|
          box.should have_tag("img", :src => "exclamation.png")
        end
      end
    end

    it "should not include an auto discovery rss link until it has stabilized" do
      get :show
      response.should_not have_tag("head link[rel=alternate][type=application/rss+xml]")
    end

    it "should not incorrectly escape html" do
      get :show
      response.should_not have_tag("span.sparkline", '&lt;span')
      Nokogiri::HTML(response.body).css('.sparkline').each do |node|
        node.to_s.should_not include '&lt;'
      end
    end

    context "when the format is rss" do
      before do
        get :show, :format => :rss
        response.should be_success
      end

      it "should respond with valid rss" do
        response.body.should include('<?xml version="1.0" encoding="UTF-8"?>')
        response.should have_tag('rss[version="2.0"]') do
          with_tag("channel") do
            with_tag("title", "Pivotal Labs CI")
            with_tag("link", "http://test.host/")
            with_tag("description", "Most recent builds and their status")
            with_tag("item")
          end
        end
      end

      describe "items" do
        before do
          @all_projects = Project.standalone
          @all_projects.should_not be_empty
        end

        it "should have a valid item for each project" do
          @all_projects.each do |project|
            response.should have_tag('rss channel item') do
              with_tag("title", /#{project.name}/)
              with_tag("link", project.status.url)
              with_tag("guid", project.status.url)
              with_tag("description")
              with_tag("pubDate", project.status.published_at.to_s)
            end
          end
        end

        it "should use static dates in the description so it doesn't keep changing all the time" do
          response.should_not have_tag('rss channel item description', /ago/)
        end


        context "when the project is green" do
          before do
            @project = @all_projects.find(&:green?)
          end

          it "should include the last built date in the description" do
            response.should have_tag("rss channel item") do
              with_tag("title", "#{@project.name} success")
              with_tag("description", /Last built/)
            end
          end
        end

        context "when the project is red" do
          before do
            @project = @all_projects.find(&:red?)
          end

          it "should include the last built date and the oldest failure date in the description" do
            response.should have_tag("rss channel item") do
              with_tag("title", "#{@project.name} failure")
              with_tag("description", /Last built/)
              with_tag("description", /Red since/)
            end
          end
        end

        context "when the project is blue" do
          before do
            @project = @all_projects.reject(&:online?).last
          end

          it "should indicate that it's inaccessible in the description" do
            response.should have_tag("rss channel item") do
              with_tag("title", "#{@project.name} offline")
              with_tag("description", 'Could not retrieve status.')
            end
          end
        end
      end
    end

    describe 'aggregate projects' do
      it "should show aggregate projects that are not empty" do
        get :show
        assigns(:projects).should include aggregate_projects(:internal_projects_aggregate)
        assigns(:projects).should_not include aggregate_projects(:empty_aggregate)
      end

      it "should not show projects that are part of an aggregated project" do
        get :show
        assigns(:projects).should_not include projects(:internal_project1)
        assigns(:projects).should_not include projects(:internal_project2)
      end

    end
  end
end
