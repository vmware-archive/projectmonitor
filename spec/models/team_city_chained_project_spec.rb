require 'spec_helper'

describe TeamCityChainedProject do
  let(:feed_url) { "http://localhost:8111/app/rest/builds?locator=running:all,buildType:(id:#{build_id})" }
  let(:build_id) { "bt1" }
  let(:project) {
    TeamCityChainedProject.new(
      :name => 'TeamCityproject',
      :feed_url => feed_url,
      :auth_username => "john",
      :auth_password => "secret"
    )
  }

  describe "#fetch_building_status" do
    before do
      UrlRetriever.stub(:retrieve_content_at).and_return(xml_text)
      TeamCityChildBuilder.stub(:parse).and_return(children)
    end

    let(:xml_text) {
      <<-XML
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <builds count="1">
          <build id="1" number="1" status="FAILURE" webUrl="/1"
      #{project_is_running ? 'running="true"' : nil}
          />
        </builds>
      XML
    }

    subject { project.fetch_building_status }

    context "when the project itself is building" do
      let(:project_is_running) { true }
      let(:children) { [ double('child project') ] }

      it { should be_building }

      it "does not query its children for their statuses" do
        children.each {|child| child.should_not_receive(:building?) }
        project.fetch_building_status
      end
    end

    context "when the project itself is not building, and it has no children" do
      let(:project_is_running) { false }
      let(:children) { Array.new }

      it { should_not be_building }
    end

    context "when the project is not building, but one of its children builds is" do
      let(:project_is_running) { false }
      let(:children) { [ double('child_project', building?: true) ] }

      it { should be_building }
    end

    context "when the project is not building and neither are its children" do
      let(:project_is_running) { false }
      let(:children) { [ double('child_project', building?: false) ] }

      it { should_not be_building }
    end
  end

  describe "#fetch_new_statuses" do
    before do
      project.save!
      UrlRetriever.stub(:retrieve_content_at).and_return(xml_text)
    end

    def fetch_new_statuses
      project.fetch_new_statuses
      project.reload
    end

    let(:now) { Time.current }

    before do
      Clock.stub(:now).and_return(now)
    end

    let(:start_time) { 1.hour.ago }
    let(:xml_text) {
      <<-XML.strip_heredoc
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <builds count="1">
          <build id="1" number="1" status="#{build_status}" webUrl="/123" startDate="#{start_time.iso8601}" />
        </builds>
      XML
    }
    let(:build_status) { 'SUCCESS' } # DEFAULT

    context "when the build is failing" do
      let(:build_status) { 'FAILURE' }

      it "creates a failing status" do
        fetch_new_statuses
        project.latest_status.should_not be_success
      end

      it "gives the status the project's last build time" do
        fetch_new_statuses
        project.latest_status.published_at.to_i.should == start_time.to_i
      end
    end

    context "when the build is passing, but one of its child builds is failing" do
      let(:build_status) { 'SUCCESS' }

      before do
        TeamCityChildBuilder.stub(:parse).with(project, anything).and_return([
          double('project child', red?: false, last_build_time: start_time + 1.hour),
          double('project child', red?: true, last_build_time: start_time)
        ])
      end

      it "creates a failing status" do
        fetch_new_statuses
        project.latest_status.should_not be_success
      end

      it "gives the status the most recent build time" do
        fetch_new_statuses
        project.latest_status.published_at.to_i.should == (start_time + 1.hour).to_i
      end
    end

    context "when the most recent build status is UNKNOWN" do
      let(:xml_text) {
        <<-XML.strip_heredoc
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <builds count="2">
            <build id="2" number="2" status="UNKNOWN" webUrl="/456" />
            <build id="1" number="1" status="#{build_status}" webUrl="/123" />
          </builds>
        XML
      }

      context "and the previous build is red" do
        let(:build_status) { 'FAILURE' }

        it "should not be successful" do
          fetch_new_statuses
          project.reload.latest_status.should_not be_success
        end
      end

      context "and the previous build is green" do
        let(:build_status) { 'SUCCESS' }

        it "should be successful" do
          fetch_new_statuses
          project.reload.latest_status.should be_success
        end
      end
    end

    context "don't create duplicate statuses" do
      before do
        project.statuses.create!(online: true, success: false, url: '/456', published_at: last_saved_build_time)
        project.reload
        TeamCityChildBuilder.stub(:parse).with(project, anything).and_return(children)
      end

      let(:xml_text) {
        <<-XML.strip_heredoc
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <builds count="2">
            <build id="2" number="2" status="SUCCESS" webUrl="/456" startDate="#{last_parent_build_time.iso8601}" />
            <build id="1" number="1" status="FAILURE" webUrl="/123" startDate="#{(last_parent_build_time - 5.minutes).iso8601}" />
          </builds>
        XML
      }

      let(:children) {[
        double('project child', red?: false, last_build_time: last_child_build_time),
        double('project child', red?: true, last_build_time: last_child_build_time - 2.minutes)
      ]}


      describe "when no builds have happened since the last status was created" do
        let(:last_saved_build_time) { 5.minutes.ago }
        let(:last_parent_build_time) { 5.minutes.ago }
        let(:last_child_build_time) { last_saved_build_time - 1.minute }

        it "should not create a new status" do
          expect { fetch_new_statuses }.to_not change(project.statuses, :count)
        end
      end

      describe "when new builds have happened for the parent since the last status was created" do
        let(:last_saved_build_time) { 5.minutes.ago }
        let(:last_parent_build_time) { Time.current }
        let(:last_child_build_time) { last_saved_build_time - 1.minute }

        it "should create a new status" do
          expect { fetch_new_statuses }.to change(project.statuses, :count).by(1)
        end
      end

      describe "when new builds have happened for the children since the last status was saved" do
        let(:last_saved_build_time) { 5.minutes.ago }
        let(:last_parent_build_time) { 5.minutes.ago }
        let(:last_child_build_time) { Time.current }

        it "should create a new status" do
          expect { fetch_new_statuses }.to change(project.statuses, :count).by(1)
        end
      end
    end

    describe "#build_id" do
      it "should use the build id in the feed_url" do
        project.build_id.should == build_id
      end
    end
  end
end
