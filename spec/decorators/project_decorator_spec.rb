require 'spec_helper'

describe ProjectDecorator do
  describe "#time_since_last_build" do
    let(:project_decorator) { ProjectDecorator.new project }
    let(:project) { Project.new }

    subject { project_decorator.time_since_last_build }

    context "project has no latest status" do
      it { should be_nil }
    end

    context "project has a latest status" do
      let(:published_at_time) { Time.now }
      before do
        project.stub(:latest_status).and_return(
          double(:latest_status, published_at: published_at_time)
        )
      end

      let(:time_distance) { [1,2].sample }

      context "< 60 seconds ago" do
        let(:published_at_time) { time_distance.second.ago }

        it { should == "#{time_distance}s"}
      end

      context "< 60 minutes ago" do
        let(:published_at_time) { time_distance.minute.ago }

        it { should == "#{time_distance}m"}
      end
      context "< 1 day ago" do
        let(:published_at_time) { time_distance.hour.ago }

        it { should == "#{time_distance}h"}
      end

      context ">= 1 day ago" do
        let(:published_at_time) { time_distance.days.ago }

        it { should == "#{time_distance}d"}
      end
    end
  end
end
