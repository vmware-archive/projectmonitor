require File.dirname(__FILE__) + '/../spec_helper'

shared_examples_for "all build history fetches" do
  it "should not create a new status entry if the status has not changed since the previous fetch" do
    status_count = @project.statuses.count
    fetch_build_history_with_xml_response(@response_xml)
    @project.statuses.count.should == status_count
  end
end

shared_examples_for "status for a valid build history xml response" do
  it_should_behave_like "all build history fetches"

  it "should be online" do
    @project.status.should be_online
  end

  it "should return the link to the checkin" do
    link_elements = @response_doc.find("/rss/channel/item/link")
    link_elements.size.should == 1
    @project.status.url.should == link_elements.first.content
  end

  it "should return the published date of the checkin" do
    date_elements = @response_doc.find("/rss/channel/item/pubDate")
    date_elements.size.should == 1
    @project.status.published_at.should == Time.parse(date_elements.first.content)
  end
end

describe StatusFetcher do

  HISTORY_SUCCESS_XML = File.read('test/fixtures/cc_rss_examples/success.rss')
  HISTORY_NEVER_GREEN_XML = File.read('test/fixtures/cc_rss_examples/never_green.rss')
  HISTORY_FAILURE_XML = File.read('test/fixtures/cc_rss_examples/failure.rss')
  HISTORY_INVALID_XML = "<foo><bar>baz</bar></foo>"

  before(:each) do
    @project = projects(:socialitis)
  end

  describe "#fetch_build_history" do
    describe "with pubDate set with epoch" do
      before(:all) do
        @parser = XML::Parser.string(@response_xml = HISTORY_NEVER_GREEN_XML)
        @response_doc = @parser.parse
      end

      before(:each) do
        fetch_build_history_with_xml_response(@response_xml)
      end

      it "should return current time" do
        @project.status.published_at.to_i.should == Clock.now.to_i
      end
    end

    describe "with reported success" do
      before(:all) do
        @parser = XML::Parser.string(@response_xml = HISTORY_SUCCESS_XML)
        @response_doc = @parser.parse
      end

      before(:each) do
        fetch_build_history_with_xml_response(@response_xml)
      end

      it_should_behave_like "status for a valid build history xml response"

      it "should report success" do
        @project.status.should be_success
        @project.status.error.should be_nil
      end
    end

    describe "with reported failure" do
      before(:all) do
        @parser = XML::Parser.string(@response_xml = HISTORY_FAILURE_XML)
        @response_doc = @parser.parse
      end

      before(:each) do
        fetch_build_history_with_xml_response(@response_xml)
      end

      it_should_behave_like "status for a valid build history xml response"

      it "should report failure" do
        @project.status.should_not be_success
      end
    end

    describe "with invalid xml" do
      before(:all) do
        @parser = XML::Parser.string(@response_xml = HISTORY_INVALID_XML)
        @response_doc = @parser.parse
      end

      before(:each) do
        fetch_build_history_with_xml_response(@response_xml)
      end

      it_should_behave_like "all build history fetches"

      it "should not be online" do
        @project.status.should_not be_online
      end
    end

    describe "with exception while parsing xml" do
      before do
        retriever = mock("mock retriever")
        retriever.should_receive(:retrieve_content_at).any_number_of_times.and_raise(Exception.new('bad error'))

        @fetcher = StatusFetcher.new(retriever)
      end

      it "should return error" do
        @fetcher.fetch_build_history(@project)[:error].should match(/#{@project.name}.*bad error/)
      end
    end
  end

  describe "#fetch_building_status" do
    BUILDING_XML = File.read('test/fixtures/building_status_examples/socialitis_building.xml')
    NOT_BUILDING_XML = File.read('test/fixtures/building_status_examples/socialitis_not_building.xml')
    BUILDING_INVALID_XML = "<foo><bar>baz</bar></foo>"

    context "with a valid response that the project is building" do
      before(:each) do
        @response_xml = BUILDING_XML
        fetch_building_status_with_xml_response(@response_xml)
      end

      it "should set the building flag on the project to true" do
        @project.should be_building
      end
    end

    context "with a project name different than CC project name" do
      before(:each) do
        @response_xml = BUILDING_XML
        @project.name = "Socialitis with different name than CC project name"
        fetch_building_status_with_xml_response(@response_xml)
      end

      it "should set the building flag on the project to true" do
        @project.should be_building
      end
    end

    context "with a RSS url with different capitalization than CC project name" do
      before(:each) do
        @response_xml = BUILDING_XML.downcase
        @project.feed_url = @project.feed_url.upcase
        fetch_building_status_with_xml_response(@response_xml)
      end

      it "should set the building flag on the project to true" do
        @project.should be_building
      end
    end

    context "with a valid response that the project is not building" do
      before(:each) do
        @response_xml = NOT_BUILDING_XML
        fetch_building_status_with_xml_response(@response_xml)
      end

      it "should set the building flag on the project to false" do
        @project.should_not be_building
      end
    end

    context "with an invalid response" do
      before(:each) do
        @response_xml = BUILDING_INVALID_XML
        fetch_building_status_with_xml_response(@response_xml)
      end

      it "should set the building flag on the project to false" do
        @project.should_not be_building
      end
    end
  end

  describe "#fetch_all" do
    context "with exception while parsing all xml" do
      before(:each) do
        retriever = mock("mock retriever")
        retriever.should_receive(:retrieve_content_at).any_number_of_times.and_raise(Exception.new('bad error'))

        @fetcher = StatusFetcher.new(retriever)
      end

      it "should fetch build history and building status for all projects needing build" do
        project_count = Project.count
        project_count.should > 1
        Project.all.each {|project| project.needs_poll?.should be_true }
        Project.first.update_attribute(:next_poll_at, 5.minutes.from_now)  # make 1 project not ready to poll

        @fetcher.should_receive(:fetch_build_history).exactly(project_count - 1).times.and_return({:success => true})
        @fetcher.should_receive(:fetch_building_status).exactly(project_count - 1).times.and_return({:building => false})
        @fetcher.should_not_receive(:fetch_build_history).with(Project.first)

        @fetcher.fetch_all

        Project.last.next_poll_at.should > Time.now
      end

      it "should raise an exception" do
        Project.all.each {|project| project.needs_poll?.should be_true }
        lambda {@fetcher.fetch_all}.should raise_error(/ALL projects had errors fetching status/)
      end
    end
  end

  private

  def fetch_build_history_with_xml_response(xml)
    fetcher_with_mocked_url_retriever(@project.feed_url, xml).fetch_build_history(@project)[:success].should_not be_nil
    @project.reload
  end

  def fetch_building_status_with_xml_response(xml)
    fetcher_with_mocked_url_retriever(@project.build_status_url, xml).fetch_building_status(@project)[:error].should be_nil
    @project.reload
  end

  def fetcher_with_mocked_url_retriever(url, xml)
    retriever = mock("mock retriever")
    retriever.should_receive(:retrieve_content_at).with(url, @project.auth_username, @project.auth_password).and_return(xml)
    StatusFetcher.new(retriever)
  end
end
