require 'spec_helper'

describe ProjectMonitorHelper, :type => :helper do
  before do
    @status = double(ProjectStatus, published_at: publish_time)
    @project = double(Project, status: @status)
  end

  describe "#static_status_messages_for" do
    def publish_time
      Time.parse('Fri May 28 17:27:11 -0700 2010')
    end

    context "when the project's status published_at & red_since is nil" do
      before do
        @status = double(ProjectStatus, published_at: nil)
        @project = double(Project, status: @status, red_since: nil)
        allow(@project).to receive(:online?).and_return(true)
        allow(@project).to receive(:failure?).and_return(true)
        allow(@project).to receive(:red_build_count).and_return(2)
      end

      it "acts as though the build were today" do
        last_built_messages = helper.static_status_messages_for(@project)
        expect(last_built_messages).to include('Last build date unknown')
        expect(last_built_messages).to include('Red for some time')
      end
    end

    context "when the project is online" do
      before do
        allow(@project).to receive(:online?).and_return(true)
        allow(@project).to receive(:failure?).and_return(false)
      end

      context "when the project isn't red" do
        it "should include the last built date" do
          messages = helper.static_status_messages_for(@project)
          expect(messages.size).to eq(1)
          last_built_message = messages.first
          expect(last_built_message).to eq("Last built #{publish_time.to_s}")
        end
      end

      context "when the project is red" do
        before do
          @red_since_time = @status.published_at - 2.days
          allow(@project).to receive(:failure?).and_return(true)
          allow(@project).to receive(:red_build_count).and_return(20)
          allow(@project).to receive(:red_since).and_return(@red_since_time)
        end

        it "should include the oldest continuous failure date" do
          messages = helper.static_status_messages_for(@project)
          expect(messages.size).to eq(2)

          failure_message = messages.last
          expect(failure_message).to eq("Red since #{@red_since_time.to_s} (20 builds)")
        end
      end
    end

    context "when the project is inaccessible" do
      before do
        allow(@project).to receive(:online?).and_return(false)
      end

      it "should an appropriate message" do
        messages = helper.static_status_messages_for(@project)
        expect(messages.size).to eq(1)

        offline_message = messages.first
        expect(offline_message).to eq('Could not retrieve status')
      end
    end
  end
end
