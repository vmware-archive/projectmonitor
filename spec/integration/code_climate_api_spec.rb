require 'spec_helper'

describe CodeClimateApi do
  context "with the real service", :vcr do
    subject { CodeClimateApi.new(project) }

    let(:project) { FactoryGirl.create :project, code_climate_api_token: "b5acc9a53efe672306c3d1dd7bb33e002aa84525", code_climate_repo_id: "50a5652f7e00a4722d00a16e" }

    context "current_gpa" do
      it "should be 3.67" do
        subject.current_gpa.should == 3.67
      end
    end

    context "previous_gpa" do
      it "should be 3.67" do
        subject.previous_gpa.should == 3.67
      end
    end
  end
end
