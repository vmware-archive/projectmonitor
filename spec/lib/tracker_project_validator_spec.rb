require 'spec_helper'

describe TrackerProjectValidator do
  describe "validate" do
    let(:project) { FactoryGirl.create(:project) }
    let(:params) { {auth_token: auth_token, project_id: project_id, id: project.id } }

    subject do
      TrackerProjectValidator.validate params
      project.reload.tracker_validation_status[:status]
    end

    context "with a valid token and valid project id" do
      let(:auth_token) { '881c7bc3264a00d280225ea409225fe8' }
      let(:project_id) { '590337' }

      before do
        allow(PivotalTracker::Project).to receive(:find).with(project_id) { true }
      end

      it { is_expected.to eq(:ok) }
    end

    context "with an invalid token and valid project id" do
      let(:auth_token) { '837458265' }
      let(:project_id) { '590337' }

      before do
        allow(PivotalTracker::Project).to receive(:find).with(project_id) { raise RestClient::Unauthorized }
      end

      it { is_expected.to eq(:unauthorized)}
    end

    context "with a valid token and invalid project id" do
      let(:auth_token) { '881c7bc3264a00d280225ea409225fe8' }
      let(:project_id) { '935729729' }

      before do
        allow(PivotalTracker::Project).to receive(:find).with(project_id) { raise RestClient::ResourceNotFound }
      end

      it { is_expected.to eq(:not_found) }
    end

    context "with a invalid token and invalid project id" do
      let(:auth_token) { '837458265' }
      let(:project_id) { '397295725' }

      before do
        allow(PivotalTracker::Project).to receive(:find).with(project_id) { raise RestClient::Unauthorized }
      end

      it { is_expected.to eq(:unauthorized) }
    end
  end
end
