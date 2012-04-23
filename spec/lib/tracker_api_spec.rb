require_relative '../../lib/tracker_api'

describe TrackerApi do
  let(:token) { "token"}
  let(:project_id) { "1" }
  let(:tracker_api) { TrackerApi.new token }
  let(:xml_response) { double :xml_response, read: xml}

  describe "#fetch_current_iteration" do
    let(:xml) do
      <<-XML
        <?xml version="1.0" encoding="UTF-8"?>
        <iterations type="array">
          <iteration>
            <id type="integer">179</id>
            <stories type="array">
              <story>
                <current_state>accepted</current_state>
              </story>
              <story>
                <current_state>unaccepted</current_state>
              </story>
            </stories>
          </iteration>
        </iterations>
      XML
    end

    let("hash_response") do
      {"id" => 179, "stories" =>[{"current_state" => "accepted"}, {"current_state" => "unaccepted"}]}
    end

    it "should open the current iteration url with the right token" do
      Kernel.should_receive(:open).with(
        "http://www.pivotaltracker.com/services/v3/projects/#{project_id}/iterations/current",
        { "X-TrackerToken" => token }
      ).and_return xml_response

      tracker_api.fetch_current_iteration(project_id)
    end

    it "should return the first iteration returned in the xml response as a hash" do
      Kernel.stub(:open).with(
        "http://www.pivotaltracker.com/services/v3/projects/#{project_id}/iterations/current",
        { "X-TrackerToken" => token }
      ).and_return xml_response

      tracker_api.fetch_current_iteration(project_id).should == hash_response
    end
  end
end
