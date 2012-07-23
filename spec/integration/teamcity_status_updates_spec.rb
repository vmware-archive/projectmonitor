require 'spec_helper'

describe "TeamCity status updates" do

  context "when a build is in progress then successful after failure" do
    let(:project) { FactoryGirl.create(:team_city_rest_project) }
    let(:building_in_progress_after_failure_xml) {
      <<-XML.strip_heredoc
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <builds count="1">
          <build id="2" number="2" status="SUCCESS" buildTypeId="bt2" href="/app/rest/builds/id:2"
                 running="true" percentageComplete="4"
                 webUrl="http://localhost:8111/viewLog.html?buildId=2&amp;buildTypeId=bt2" startDate="#{10.minutes.ago.to_s(:db)}"/>
          <build id="1" number="1" status="FAILURE" buildTypeId="bt1" href="/app/rest/builds/id:1"
                 webUrl="http://localhost:8111/viewLog.html?buildId=1&amp;buildTypeId=bt1" startDate="#{20.minutes.ago.to_s(:db)}"/>
        </builds>
      XML
    }
    let(:success_after_build_in_progress_xml) {
      <<-XML.strip_heredoc
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <builds count="1">
          <build id="2" number="2" status="SUCCESS" buildTypeId="bt2" href="/app/rest/builds/id:2"
                 webUrl="http://localhost:8111/viewLog.html?buildId=2&amp;buildTypeId=bt2" startDate="#{10.minutes.ago.to_s(:db)}"/>
          <build id="1" number="1" status="FAILURE" buildTypeId="bt1" href="/app/rest/builds/id:1"
                 webUrl="http://localhost:8111/viewLog.html?buildId=1&amp;buildTypeId=bt1" startDate="#{20.minutes.ago.to_s(:db)}"/>
        </builds>
      XML
    }

    it "updates the status of the build" do
      project.should have(0).statuses
      project.should_not be_building

      ProjectContentFetcher.any_instance.stub(:fetch).and_return(building_in_progress_after_failure_xml)
      StatusFetcher.retrieve_status_for(project)
      project.reload

      project.should have(1).statuses
      project.latest_status.should_not be_success
      project.should be_building

      ProjectContentFetcher.any_instance.stub(:fetch).and_return(success_after_build_in_progress_xml)
      StatusFetcher.retrieve_status_for(project)
      project.reload

      project.should have(2).statuses
      project.should_not be_building
      project.latest_status.should be_success
    end
  end

  context "when a build is in progress and failing, then finishes" do
    let(:project) { FactoryGirl.create(:team_city_rest_project) }
    let(:failing_build_in_progress_xml) {
      <<-XML.strip_heredoc
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <builds count="1">
          <build id="1" number="1" status="FAILURE" buildTypeId="bt2" href="/app/rest/builds/id:1"
                 running="true" percentageComplete="4"
                 webUrl="http://localhost:8111/viewLog.html?buildId=1&amp;buildTypeId=bt1"/>
        </builds>
      XML
    }
    let(:failed_build) {
      <<-XML.strip_heredoc
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <builds count="1">
          <build id="1" number="1" status="FAILURE" buildTypeId="bt2" href="/app/rest/builds/id:1"
                 webUrl="http://localhost:8111/viewLog.html?buildId=1&amp;buildTypeId=bt1"/>
        </builds>
      XML
    }


    it "updates the status of the build" do
      project.should have(0).statuses
      project.should_not be_building

      ProjectContentFetcher.any_instance.stub(:fetch).and_return(failing_build_in_progress_xml)
      StatusFetcher.retrieve_status_for(project)
      project.reload

      project.should have(1).statuses
      project.should be_building

      ProjectContentFetcher.any_instance.stub(:fetch).and_return(failed_build)
      StatusFetcher.retrieve_status_for(project)
      project.reload

      project.should have(1).statuses
      project.should_not be_building
      project.latest_status.should_not be_success
    end
  end

  # should take the last finished build status when later builds are in progress


  # (start red) in progress build finishes and passes after another build begins

  # in progress build that begins to fail
  # in progress build finishes and fails
  # in progress build finishes and passes
  # (start green) in progress build fails and later in progress build is still passing => fail
end
