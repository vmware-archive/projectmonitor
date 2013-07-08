require 'spec_helper'

describe ProjectMonitorHelper do
  before do
    @status = double(ProjectStatus, :published_at => publish_time)
    @project = double(Project, :status => @status)
  end

  describe "#static_status_messages_for" do
    def publish_time
      Time.parse('Fri May 28 17:27:11 -0700 2010')
    end

    context "when the project's status published_at & red_since is nil" do
      before do
        @status = double(ProjectStatus, :published_at => nil)
        @project = double(Project, :status => @status, :red_since => nil)
        @project.stub(:online?).and_return(true)
        @project.stub(:red?).and_return(true)
        @project.stub(:red_build_count).and_return(2)
      end

      it "acts as though the build were today" do
        last_built_messages = helper.static_status_messages_for(@project)
        last_built_messages.should include('Last build date unknown')
        last_built_messages.should include('Red for some time')
      end
    end

    context "when the project is online" do
      before do
        @project.stub(:online?).and_return(true)
        @project.stub(:red?).and_return(false)
      end

      context "when the project isn't red" do
        it "should include the last built date" do
          messages = helper.static_status_messages_for(@project)
          messages.should have(1).message
          last_built_message = messages.first
          last_built_message.should == "Last built #{publish_time.to_s}"
        end
      end

      context "when the project is red" do
        before do
          @red_since_time = @status.published_at - 2.days
          @project.stub(:red?).and_return(true)
          @project.stub(:red_build_count).and_return(20)
          @project.stub(:red_since).and_return(@red_since_time)
        end

        it "should include the oldest continuous failure date" do
          messages = helper.static_status_messages_for(@project)
          messages.should have(2).messages

          failure_message = messages.last
          failure_message.should == "Red since #{@red_since_time.to_s} (20 builds)"
        end
      end
    end

    context "when the project is inaccessible" do
      before do
        @project.stub(:online?).and_return(false)
      end

      it "should an appropriate message" do
        messages = helper.static_status_messages_for(@project)
        messages.should have(1).message

        offline_message = messages.first
        offline_message.should == 'Could not retrieve status'
      end
    end
  end
end
