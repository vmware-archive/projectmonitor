require 'spec_helper'
require 'time'

describe HomeController do
  let!(:projects) { [FactoryGirl.create(:jenkins_project)] }
  let!(:aggregate_project) { FactoryGirl.create(:aggregate_project) }
  let!(:aggregate_projects) { [aggregate_project] }

  describe "#index" do
    let(:tags) { 'bleecker' }

    before do
      AggregateProject.stub(:displayable).and_return(aggregate_projects)
      Project.stub_chain(:standalone, :displayable).and_return(projects)
      projects.stub_chain(:concat, :sort_by).and_return(projects + aggregate_projects)
    end

    it "should render collection of projects as JSON" do
      get :index
      assigns(:projects).should == (projects + aggregate_projects)
    end

    it 'gets a collection of aggregate projects by tag' do
      AggregateProject.should_receive(:displayable).with(tags)
      projects.stub(:take).and_return(projects)
      get :index, tags: tags
    end
  end

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
  end

  context 'when github status is checked' do
    context 'and there is an error' do
      context 'and the request throws an error' do
        let(:error) { Net::HTTPError.new("", nil) }

        before do
          UrlRetriever.any_instance.should_receive(:retrieve_content).and_raise(error)
        end

        it "returns 'unreachable'" do
          get :github_status, format: :json
          response.body.should == '{"status":"unreachable"}'
        end
      end
    end

    context 'when github is reachable' do
      before do
        ExternalDependency.stub(:get_or_fetch) { '{"status":"minor-outage"}' }
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
          ExternalDependency.stub(:get_or_fetch) { '{"status":"unreachable"}' }
        end

        it "returns 'unreachable'" do
          get :heroku_status, format: :json
          response.body.should == '{"status":"unreachable"}'
        end
      end
    end

    context 'when heroku is reachable' do
      before do
        ExternalDependency.stub(:get_or_fetch) { '{"status":"minor-outage"}' }
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
          ExternalDependency.stub(:get_or_fetch) { '{"status":"unreachable"}' }
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
            ExternalDependency.stub(:get_or_fetch) { '{"status":"page broken"}' }
          end

          it "returns 'page broken'" do
            get :rubygems_status, format: :json
            response.body.should == '{"status":"page broken"}'
          end
        end

        context 'and the content is different than we expect' do
          before do
            ExternalDependency.stub(:get_or_fetch) { '{"status":"page broken"}' }
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
          ExternalDependency.stub(:get_or_fetch) { '{"status":"good"}' }
        end

        it "parses out the status from rubygems" do
          get :rubygems_status, format: :json
          response.body.should == '{"status":"good"}'
        end
      end

      context "and returns not UP" do
        before do
          ExternalDependency.stub(:get_or_fetch) { '{"status":"bad"}' }
        end

        it "parses out the status from rubygems" do
          get :rubygems_status, format: :json
          response.body.should == '{"status":"bad"}'
        end
      end
    end
  end
end
