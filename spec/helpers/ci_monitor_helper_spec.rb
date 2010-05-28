require File.dirname(__FILE__) + '/../spec_helper'

describe CiMonitorHelper do
  describe "#status_messages_for" do
    before do
      @yesterday = Time.now - 1.day
      @status = stub(ProjectStatus, :published_at => @yesterday)
      @project = stub(Project, :status => @status)
    end

    context "when the project is online" do
      before do
        @project.stub!(:online?).and_return(true)
        @project.stub!(:red?).and_return(false)
      end

      context "when the project isn't red" do
        it "should include the last built date" do
          messages = helper.status_messages_for(@project)
          messages.should have(1).message
          last_built_message = messages.first
          last_built_message.should == ['project_published_at', 'Last built 1 day ago']
        end
      end

      context "when the project is red" do
        before do
          @project.stub!(:red?).and_return(true)
          @project.stub!(:red_build_count).and_return(20)
          @project.stub!(:red_since).and_return(@yesterday - 2.days)
        end

        it "should include the oldest continuous failure date" do
          messages = helper.status_messages_for(@project)
          messages.should have(2).messages

          failure_message = messages.last
          failure_message.should == ['project_red_since', 'Red since 3 days ago (20 builds)']
        end
      end
    end

    context "when the project is offline" do
      before do
        @project.stub!(:online?).and_return(false)
      end

      it "should an appropriate message" do
        messages = helper.status_messages_for(@project)
        messages.should have(1).message

        offline_message = messages.first
        offline_message.should == ['project_invalid', 'Could not retrieve status']
      end
    end
  end
end
