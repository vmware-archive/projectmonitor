require 'spec_helper'

describe DashboardsController do
  render_views

  describe "routes" do
    it "should map /dashboard to #show" do
      {:get => "/dashboard"}.should route_to(:controller => 'dashboards', :action => 'show')
    end
  end

  describe "#show" do

    let(:page) { Capybara::Node::Simple.new(response.body) }

    it "should succeed" do
      get :show
      response.should be_success
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


    it "should show projects with a given tag unless an aggregate has that tag name" do
      internal_project_3 = projects(:internal_project3)
      internal_project_3.tag_list = 'independent'
      internal_project_3.save!

      get :show, :size => 'tiny', :tags => "independent"
      assigns(:projects).map(&:name).should include(internal_project_3.name)
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
        page.find("#project_#{project.id}").tap do |box|
          box.should have_css(".sparkline.building")
        end
      end
    end

    it "should display a green spinner for green building projects" do
      get :show
      green_building_projects = Project.find(:all, :conditions => {:enabled => true, :building => true}).select(&:green?)
      green_building_projects.should_not be_empty
      green_building_projects.each do |project|
        page.find("#project_#{project.id}").tap do |box|
          box.should have_css(".sparkline.building")
        end
      end
    end

    it "should display a checkmark for green projects not building" do
      get :show
      not_building_projects = Project.standalone.reject(&:building?).select(&:green?)
      not_building_projects.should_not be_empty
      not_building_projects.each do |project|
        page.should have_css("#project_#{project.id}.success")
      end
    end

    it "should display an exclamation for red projects not building" do
      get :show
      not_building_projects = Project.standalone.reject(&:building?).select(&:red?)
      not_building_projects.should_not be_empty
      not_building_projects.each do |project|
        page.should have_css("#project_#{project.id}.failure")
      end
    end

    describe "offline projects" do
      it "should display a grey tile" do
        get :show
        offline_projects = Project.standalone.reject(&:green?).reject(&:red?)
        offline_projects.should_not be_empty
        offline_projects.each do |project|
          page.should have_css("#project_#{project.id}.offline")
        end
      end
    end

    it "should not include an auto discovery rss link until it has stabilized" do
      get :show
      page.should_not have_css("head link[rel='alternate'][type='application/rss+xml']")
    end

    it "should not incorrectly escape html" do
      get :show
      page.should_not have_css("span.sparkline", text: '&lt;span')
      page.all('.sparkline').each do |node|
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
        page.should have_css('rss[version="2.0"]')
        page.should have_css('channel')
        page.should have_css('channel title')
        #capybara does not expect <link> to have text in them - hence the following always fails
        #page.should have_css('channel link', text: "http://test.host/")
        page.should have_css('channel description', text: "Most recent builds and their status")
        page.should have_css('channel item')
      end

      describe "items" do
        before do
          @all_projects = Project.standalone
          @all_projects.should_not be_empty
        end

        it "should have a valid item for each project" do
          @all_projects.each do |project|
            page.should have_css('rss channel item title', text: /#{project.name}/)
            #capybara does not expect <link> to have text in them - hence the following always fails
            #page.should have_css('rss channel item link', text: project.status.url)
            page.should have_css('rss channel item guid', text: project.status.url)
            page.should have_css('rss channel item description')
            #using pubdate instead of pubDate - refer https://github.com/jnicklas/capybara/issues/489
            page.should have_css('rss channel item pubdate', text: project.status.published_at.to_s)
          end
        end

        it "should use static dates in the description so it doesn't keep changing all the time" do
          page.should_not have_css('rss channel item description', text: /ago/)
        end

        context "when the project is green" do
          before do
            @project = @all_projects.find(&:green?)
          end

          it "should include the last built date in the description" do
            page.find("rss channel item").tap do |item|
              item.should have_css("title", "#{@project.name} success")
              item.should have_css("description", text: /Last built/)
            end
          end
        end

        context "when the project is red" do
          before do
            @project = @all_projects.find(&:red?)
          end

          it "should include the last built date and the oldest failure date in the description" do
            page.find("rss channel item") do |item|
              item.should have_css("title", "#{@project.name} failure")
              item.should have_css("description", text: /Last built/)
              item.should have_css("description", text: /Red since/)
            end
          end
        end

        context "when the project is grey" do
          before do
            @project = @all_projects.reject(&:online?).last
          end

          it "should indicate that it's inaccessible in the description" do
            page.find("rss channel item").tap do |item|
              item.should have_css("title", "#{@project.name} offline")
              item.should have_css("description", 'Could not retrieve status.')
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
