require 'spec_helper'

describe DashboardsController do
  let(:project) { FactoryGirl.build(:project) }
  let(:aggregate_project) { FactoryGirl.build(:aggregate_project) }

  describe "index" do
    before do
      DashboardGrid.stub(:generate).and_return(projects)
    end

    context "format html" do
      before do
        get :index, :format => :html
      end

      it "should render_template :index" do
        response.should render_template :index
      end
    end

    context "format json" do
      let(:projects) { double(:projects, :to_json => "{ foo: bar }" ) }

      before do
        get :index, :format => :json
      end

      it "should render :json => @projects" do
        response.body.should == "{ foo: bar }"
      end
    end
  end
end
