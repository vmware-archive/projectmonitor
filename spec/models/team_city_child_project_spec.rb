require 'spec_helper'

describe TeamCityChildProject do
  let(:feed_url) { "http://localhost:8111/app/rest/builds?locator=running:all,buildType:(id:#{build_id})" }
  let(:build_id) { "bt1" }
  let(:project) {
    TeamCityChildProject.new(
      :feed_url => feed_url,
      :auth_username => "john",
      :auth_password => "secret",
      :build_id => build_id
    )
  }

  describe "#last_build_time" do
    subject { project.last_build_time }
    before do
      UrlRetriever.stub(:retrieve_content_at).and_return(xml_text)
      TeamCityChildBuilder.stub(:parse).and_return(children)
    end

    let(:xml_text) {
      <<-XML
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <builds count="1">
          <build id="1" number="1" status="SUCCESS" webUrl="/123" startDate="#{project_build_time.iso8601}" />
        </builds>
      XML
    }

    context "when it has no children" do
      let(:project_build_time) { 5.minutes.ago }
      let(:children) { [] }

      it "uses the project's build time'" do
        project.last_build_time.to_i.should == project_build_time.to_i
      end
    end

    context "when its build time is more recent than any of its children's" do
      let(:project_build_time) { 1.minute.ago }
      let(:children) { [ double('child project', last_build_time: 1.hour.ago ) ] }

      it "uses the latest child project's build time'" do
        project.last_build_time.to_i.should == project_build_time.to_i
      end
    end

    context "when its build time is less recent than one of its children's" do
      let(:project_build_time) { 5.minutes.ago }
      let(:child_build_time) { 1.minute.ago }
      let(:children) { [ double('child project', last_build_time: child_build_time ) ] }

      it "uses the latest child project's build time'" do
        project.last_build_time.to_i.should == child_build_time.to_i
      end
    end
  end

  describe "#red?" do
    subject { project }

    context "when it can retrieve the build status" do
      before do
        UrlRetriever.stub(:retrieve_content_at).and_return(xml_text)
        TeamCityChildBuilder.stub(:parse).and_return(children)
      end

      let(:xml_text) {
        <<-XML.strip_heredoc
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <builds count="1">
            <build id="1" number="1" status="#{build_status}" webUrl="/123" />
          </builds>
        XML
      }
      let(:children) { [] }

      context "when the build is red" do
        let(:build_status) { 'FAILURE' }

        it { should be_red }
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

          it { should be_red }
        end

        context "and the previous build is green" do
          let(:build_status) { 'SUCCESS' }

          it { should_not be_red }
        end
      end

      context "when the build is green and there are no children" do
        let(:build_status) { 'SUCCESS' }

        it { should_not be_red }
      end

      context "when the build is green, but one of the children is red" do
        let(:build_status) { 'SUCCESS' }
        let(:children) {
          [ mock('child project', red?: false),
            mock('child project', red?: true), ]
        }

        it { should be_red }
      end

      context "when the build is green and all of the children are green" do
        let(:build_status) { 'SUCCESS' }
        let(:children) {
          [ mock('child project', red?: false),
            mock('child project', red?: false), ]
        }

        it { should_not be_red }
      end
    end

    context "when it cannot retrieve the build status" do

    end
  end
end
