require 'spec_helper'

describe CiMonitorHelper do
  before do
    @status = stub(ProjectStatus, :published_at => publish_time)
    @project = stub(Project, :status => @status)
  end

  describe "#relative_status_messages_for" do
    def publish_time
      Time.now - 1.day
    end

    context "when the project's status published_at & red_since is nil" do
      before do
        @status = stub(ProjectStatus, :published_at => nil)
        @project = stub(Project, :status => @status, :red_since => nil)
        @project.stub!(:online?).and_return(true)
        @project.stub!(:red?).and_return(true)
        @project.stub!(:red_build_count).and_return(1)
      end

      it "acts as though the build were today" do
        last_built_messages = helper.relative_status_messages_for(@project)
        last_built_messages.should include(['project_published_at', 'Last build date unknown'])
        last_built_messages.should include(['project_red_since', 'Red for some time'])
      end
    end

    context "when the project is online" do
      before do
        @project.stub!(:online?).and_return(true)
        @project.stub!(:red?).and_return(false)
      end

      context "when the project isn't red" do
        it "should include the last built date" do
          messages = helper.relative_status_messages_for(@project)
          messages.should have(1).message
          last_built_message = messages.first
          last_built_message.should == ['project_published_at', 'Last built 1 day ago']
        end
      end

      context "when the project is red" do
        before do
          @project.stub!(:red?).and_return(true)
          @project.stub!(:red_build_count).and_return(20)
          @project.stub!(:red_since).and_return(@status.published_at - 2.days)
        end

        it "should include the oldest continuous failure date" do
          messages = helper.relative_status_messages_for(@project)
          messages.should have(2).messages

          failure_message = messages.last
          failure_message.should == ['project_red_since', 'Red since 3 days ago (20 builds)']
        end
      end
    end

    context "when the project is inaccessible" do
      before do
        @project.stub!(:online?).and_return(false)
      end

      it "should an appropriate message" do
        messages = helper.relative_status_messages_for(@project)
        messages.should have(1).message

        offline_message = messages.first
        offline_message.should == ['project_invalid', 'Could not retrieve status']
      end
    end
  end

  describe "#static_status_messages_for" do
    def publish_time
      Time.parse('Fri May 28 17:27:11 -0700 2010')
    end
    
    context "when the project's status published_at & red_since is nil" do
      before do
        @status = stub(ProjectStatus, :published_at => nil)
        @project = stub(Project, :status => @status, :red_since => nil)
        @project.stub!(:online?).and_return(true)
        @project.stub!(:red?).and_return(true)
        @project.stub!(:red_build_count).and_return(1)
      end

      it "acts as though the build were today" do
        last_built_messages = helper.static_status_messages_for(@project)
        last_built_messages.should include('Last build date unknown')
        last_built_messages.should include('Red for some time')
      end
    end

    context "when the project is online" do
      before do
        @project.stub!(:online?).and_return(true)
        @project.stub!(:red?).and_return(false)
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
          @project.stub!(:red?).and_return(true)
          @project.stub!(:red_build_count).and_return(20)
          @project.stub!(:red_since).and_return(@red_since_time)
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
        @project.stub!(:online?).and_return(false)
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
