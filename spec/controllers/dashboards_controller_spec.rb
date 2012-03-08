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
          response.should have_selector(%Q{a[href="#{login_path}"]})
        end

        describe "logged in links" do
          before(:each) do
            log_in(create_user)
          end

          it "renders link to /users/new" do
            get :show
            response.should be_success
            response.should have_selector(%Q{a[href="#{new_user_path}"]})
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
          response.should have_selector(%Q{a[href="#{new_openid_path}"]})
        end

        describe "logged in links" do
          before(:each) do
            log_in(create_user)
          end

          it "renders link to /users/new" do
            get :show
            response.should be_success
            response.should_not have_selector(%Q{a[href="#{new_user_path}"]})
          end
        end
      end

      describe "skins" do
        it "should display the skin supplied by the 'skin' query param" do
          get :show, :skin => 'dark'
          response.should render_template('layouts/skins/dark')
        end

        it "should display the default layout if skin doesn't exist or isn't specified" do
          DashboardsController.any_instance.should_not_receive(:render).with(:layout)
          get :show, :skin => 'fake'
          response.should render_template('layouts/application')

          get :show
          response.should render_template('layouts/application')
        end
      end
    end

    it "should filter by tag" do
      nyc_projects = Project.find_tagged_with('NYC')
      nyc_projects.should_not be_empty

      aggregate_nyc_projects = AggregateProject.find_tagged_with('NYC')
      aggregate_nyc_projects.reject! { |project| !project.enabled? }
      aggregate_nyc_projects.should_not be_empty

      get :show, :size => 'tiny', :tags => 'NYC'
      assigns(:projects).should =~ [nyc_projects, aggregate_nyc_projects].flatten
    end

    it "should sort across projects and aggregate projects" do
      get :show
      assigns(:projects).map(&:name).should == ["Aggregation", "Green Currently Building", "Lumos", "Many Builds", "Never built", "Offline", "Pivots", "Red Currently Building", "Socialitis"]
    end

    it "should sort across projects and aggregate projects specifying tags" do
      get :show, :tags => 'NYC'
      assigns(:projects).map(&:name).should == ["Aggregation", "Pivots", "Socialitis"]
    end

    it "should not show child projects that are in an aggregate project when a tag matches both" do
      internal_nyc_project1 = projects(:internal_project1)
      internal_nyc_project1.tag_list = 'NYC'
      internal_nyc_project1.save!

      get :show, :size => 'tiny', :tags => 'NYC'
      assigns(:projects).map(&:name).should_not include(internal_nyc_project1.name)
    end

    it "should not store the most recent request location" do
      session[:location] = nil
      get :show
      session[:location].should be_nil
    end

    it "should have classes building and red for red building projects" do
      get :show
      building_projects = Project.find(:all, :conditions => {:enabled => true, :building => true}).select(&:red?)
      building_projects.should_not be_empty
      building_projects.each do |project|
        response.should have_selector("div.box[project_id='#{project.id}'] div.building.red")
      end
    end

    it "should have classes building and green for green building projects" do
      get :show
      green_building_projects = Project.find(:all, :conditions => {:enabled => true, :building => true}).select(&:green?)
      green_building_projects.should_not be_empty
      green_building_projects.each do |project|
        response.should have_selector("div.box[project_id='#{project.id}'] div.building.green")
      end
    end

    it "should have class green and not building for green projects not building" do
      get :show
      not_building_projects = Project.standalone.reject(&:building?).select(&:green?)
      not_building_projects.should_not be_empty
      not_building_projects.each do |project|
        response.should have_selector("div.box[project_id='#{project.id}'] div.green:not(.building)")
      end
    end

    it "should have class red and not building for red projects not building" do
      get :show
      not_building_projects = Project.standalone.reject(&:building?).select(&:red?)
      not_building_projects.should_not be_empty
      not_building_projects.each do |project|
        response.should have_selector("div.box[project_id='#{project.id}'] div.red:not(.building)")
      end
    end

    it "should not include an auto discovery rss link until it has stabilized" do
      get :show
      response.should_not have_selector("head link[rel=alternate][type='application/rss+xml']")
    end

    it "should not incorrectly escape html" do
      get :show
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
        response.should have_selector('rss[version="2.0"]') do
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
            response.should have_selector('rss channel item') do
              with_tag("title", /#{project.name}/)
              with_tag("link", project.status.url)
              with_tag("guid", project.status.url)
              with_tag("description")
              with_tag("pubDate", project.status.published_at.to_s)
            end
          end
        end

        it "should use static dates in the description so it doesn't keep changing all the time" do
          response.should_not have_selector('rss channel item description:contains("ago")')
        end


        context "when the project is green" do
          before do
            @project = @all_projects.find(&:green?)
          end

          it "should include the last built date in the description" do
            response.should have_selector("rss channel item") do
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
            response.should have_selector("rss channel item") do
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
            response.should have_selector("rss channel item") do
              with_tag("title", "#{@project.name} offline")
              with_tag("description", 'Could not retrieve status.')
            end
          end
        end
      end
    end

    context "messages" do
      before do
        @tag = 'nyc'
        @message_active = Message.create(:text => 'foo', :expires_at => 1.hour.from_now)
        @message_expired = Message.create(:text => 'foo', :expires_at => 1.hour.ago)
        @message_matching_tag = Message.create(:text => 'foo', :expires_at => 1.hour.from_now, :tag_list => @tag)
        @message_expired_matching_tag = Message.create(:text => 'foo', :expires_at => 1.hour.ago, :tag_list => @tag)
        @message_not_matching_tag = Message.create(:text => 'foo', :expires_at => 1.hour.from_now, :tag_list => 'notnyc')
      end

      it "loads all active messages without tags" do
        get :show

        assigns(:messages).should include(@message_active)
        assigns(:messages).should_not include(@message_expired)
        assigns(:messages).should include(@message_matching_tag)
        assigns(:messages).should_not include(@message_expired_matching_tag)
        assigns(:messages).should include(@message_not_matching_tag)
      end

      it "loads all active messages with specified tags" do
        get :show, :tags => @tag

        assigns(:messages).should_not include(@message_active)
        assigns(:messages).should_not include(@message_expired)
        assigns(:messages).should include(@message_matching_tag)
        assigns(:messages).should_not include(@message_expired_matching_tag)
        assigns(:messages).should_not include(@message_not_matching_tag)
      end
    end

    context "twitter searches" do
      before do
        @tag = 'nyc'
        @twitter_search_no_tag = TwitterSearch.create(:search_term => '@pivotallabs')
        @twitter_search_matching_tag = TwitterSearch.create(:search_term => '@pivotaltracker', :tag_list => @tag)
        @twitter_search_not_matching_tag = TwitterSearch.create(:search_term => '@pivotal', :tag_list => 'notnyc')
      end

      it "loads all active tweets without tags" do
        get :show

        assigns(:twitter_searches).should include(@twitter_search_no_tag)
        assigns(:twitter_searches).should include(@twitter_search_matching_tag)
        assigns(:twitter_searches).should include(@twitter_search_not_matching_tag)
      end

      it "loads all tweets with specified tags" do
        get :show, :tags => @tag

        assigns(:twitter_searches).should_not include(@twitter_search_active)
        assigns(:twitter_searches).should include(@twitter_search_matching_tag)
        assigns(:twitter_searches).should_not include(@twitter_search_not_matching_tag)
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
