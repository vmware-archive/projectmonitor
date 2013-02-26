require 'spec_helper'

describe CodeClimateApi do
  describe "a Code Climate call to a project" do
    let(:project) { double(:project, code_climate_api_token: '1111', code_climate_repo_id: '50a5652f7e00a4722d00a16e')}
    let(:code_climate_api) { CodeClimateApi.new(project) }
    let(:url_retriever) { double }

    before do
      UrlRetriever.stub(:new).and_return(url_retriever)
      url_retriever.stub(:retrieve_content) { response }
    end

    describe "a valid API response" do
      let(:response) do
        '{"last_snapshot":{"gpa":3.67},"previous_snapshot":{"gpa":3.9}}'
      end

      it "gets current GPA" do
        code_climate_api.current_gpa.should == BigDecimal("3.67")
      end

      it "gets the previous GPA" do
        code_climate_api.previous_gpa.should == BigDecimal("3.9")
      end

      it "calls the API once" do
        url_retriever.should_receive(:retrieve_content).exactly(1).times
        code_climate_api.current_gpa
        code_climate_api.previous_gpa
        code_climate_api.current_gpa
      end
    end

    describe "a broken API response" do
      let(:response) { "GARBAGE@." }

      it "returns nil" do
        code_climate_api.current_gpa.should == nil
      end

      it "calls the API twice if there is an error" do
        url_retriever.should_receive(:retrieve_content).exactly(2).times
        code_climate_api.current_gpa
        code_climate_api.current_gpa
      end
    end

    describe "missing the fields used" do
      let(:response) do
        '{"previous_snapshot":{"gpa":3.9}}'
      end

      it "returns nil for current GPA" do
        code_climate_api.current_gpa.should == nil
      end

      it "returns nil for GPA change from previous" do
        code_climate_api.gpa_change_from_previous.should == nil
      end
    end
  end
end
