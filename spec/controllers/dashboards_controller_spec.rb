require 'spec_helper'

describe DashboardsController do

  describe '#index' do
    let(:projects) { double(:projects) }
    let(:aggregate_project) { double(:aggregate_project) }
    let(:aggregate_projects) { double(:aggregate_projects) }

    context 'when an aggregate project id is specified' do
      before do
        AggregateProject.stub(:find).and_return(aggregate_project)
        aggregate_project.stub_chain(:projects, :displayable).and_return(projects)
        projects.stub_chain(:concat, :sort_by).and_return(projects)
      end

      it 'loads the specified project' do
        AggregateProject.should_receive(:find).with('1')
        projects.stub(:take).and_return(projects)
        get :index, aggregate_project_id: 1
      end

      context 'when no tile count is passed in' do
        it 'should limit the tiles by 15' do
          projects.should_receive(:take).with(15)
          get :index, aggregate_project_id: 1
        end
      end

      context 'when a tile count is passed in' do
        it 'should limit the tiles by the passed in amount' do
          projects.should_receive(:take).with(63)
          get :index, tiles_count: 63, aggregate_project_id: 1
        end
      end
    end

    context 'when the aggregate project id is not specified' do
      let(:tags) { 'bleecker' }

      before do
        AggregateProject.stub(:displayable).and_return(aggregate_projects)
        Project.stub_chain(:standalone, :displayable).and_return(projects)
        projects.stub_chain(:concat, :sort_by).and_return(projects)
      end

      it 'gets a collection of aggregate projects by tag' do
        AggregateProject.should_receive(:displayable).with(tags)
        projects.stub(:take).and_return(projects)
        get :index, tags: tags
      end

      context 'when no tile count is passed in' do
        it 'should limit the tiles by 15' do
          projects.should_receive(:take).with(15)
          get :index
        end
      end

      context 'when a tile count is passed in' do
        it 'should limit the tiles by the passed in amount' do
          projects.should_receive(:take).with(63)
          get :index, tiles_count: 63
        end
      end
    end
  end

  context 'when github status is checked' do
    context 'and there is an error' do
      context 'and the request throws an error' do
        let(:error) { Net::HTTPError.new("", nil) }

        before do
          UrlRetriever.should_receive(:retrieve_content_at).and_raise(error)
        end


        it "returns 'unreachable'" do
          get :github_status, format: :json
          response.body.should == '{"status":"unreachable"}'
        end
      end
    end

    context 'when github is reachable' do
      before do
        UrlRetriever.should_receive(:retrieve_content_at).and_return('{"status":"minor-outage"}')
      end

      it "returns whatever status github returns" do
        get :github_status, format: :json
        response.body.should == '{"status":"minor-outage"}'
      end
    end
  end

  context 'when heroku status is checked' do
    context 'and there is an error' do
      context 'and the request throws an error' do
        let(:error) { Net::HTTPError.new("", nil) }

        before do
          UrlRetriever.should_receive(:retrieve_content_at).and_raise(error)
        end

        it "returns 'unreachable'" do
          get :heroku_status, format: :json
          response.body.should == '{"status":"unreachable"}'
        end
      end
    end

    context 'when heroku is reachable' do
      before do
        UrlRetriever.should_receive(:retrieve_content_at).and_return('{"status":"minor-outage"}')
      end

      it "returns whatever status heroku returns" do
        get :heroku_status, format: :json
        response.body.should == '{"status":"minor-outage"}'
      end
    end
  end

  context 'when rubygems status is checked' do
    context 'and there is an error' do
      context 'retrieving the content' do
        let(:error) { Net::HTTPError.new("", nil) }

        before do
          UrlRetriever.should_receive(:retrieve_content_at).and_raise(error)
        end

        it "returns 'unreachable'" do
          get :rubygems_status, format: :json
          response.body.should == '{"status":"unreachable"}'
        end
      end

      context 'parsing the content' do
        context 'and the content is not valid HTML' do
          let(:error) { Nokogiri::SyntaxError.new }

          before do
            UrlRetriever.should_receive(:retrieve_content_at).and_raise(error)
          end

          it "returns 'page broken'" do
            get :rubygems_status, format: :json
            response.body.should == '{"status":"page broken"}'
          end
        end

        context 'and the content is different than we expect' do
          before do
            UrlRetriever.should_receive(:retrieve_content_at).and_return('<div class="current-status"> RubyGems.org Status: <strong>ANYTHING</strong></div>')
          end

          it "parses out the status from rubygems" do
            get :rubygems_status, format: :json
            response.body.should == '{"status":"page broken"}'
          end

        end
      end
    end

    context 'when rubygems is reachable' do
      context "and returns UP" do
        before do
          UrlRetriever.should_receive(:retrieve_content_at).and_return('<div class="current"> RubyGems.org Status: <span class="color color-up">UP</span></div>')
        end

        it "parses out the status from rubygems" do
          get :rubygems_status, format: :json
          response.body.should == '{"status":"good"}'
        end
      end

      context "and returns PARTIAL" do
        before do
          UrlRetriever.should_receive(:retrieve_content_at).and_return('<div class="current"> RubyGems.org Status: <span class="color color-up">PARTIAL/span></div>')
        end

        it "parses out the status from rubygems" do
          get :rubygems_status, format: :json
          response.body.should == '{"status":"bad"}'
        end
      end
    end
  end
end
