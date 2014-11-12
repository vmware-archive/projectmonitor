require 'spec_helper'

describe CircleCiProject, :type => :model do

  describe 'validations' do
    it { is_expected.to validate_presence_of(:ci_build_identifier) }
    it { is_expected.to validate_presence_of(:ci_auth_token) }
    it { is_expected.to validate_presence_of(:circleci_username) }
  end

  describe 'model' do
    it { is_expected.to validate_presence_of(:ci_auth_token) }
    it { is_expected.to validate_presence_of(:ci_build_identifier) }
  end

  describe 'accessors' do
    subject { build(:circleci_project, branch_name: branch_name) }
    let(:branch_name) { "foo" }

    describe "branch related" do
      context "when a branch is specified" do
        let(:branch_name) { "foo" }

        describe '#feed_url' do
          it { expect(subject.feed_url).to eq('https://circleci.com/api/v1/project/username/a-project/tree/foo?circle-token=b5bb9d8014a0f9b1d61e21e796d78dccdf1352f2') }
        end

        describe '#build_status_url' do
          it { expect(subject.build_status_url).to eq('https://circleci.com/api/v1/project/username/a-project/tree/foo?circle-token=b5bb9d8014a0f9b1d61e21e796d78dccdf1352f2') }
        end
      end

      context "when a branch is not specified" do
        let(:branch_name) { nil }

        describe '#feed_url' do
          it { expect(subject.feed_url).to eq('https://circleci.com/api/v1/project/username/a-project/tree/master?circle-token=b5bb9d8014a0f9b1d61e21e796d78dccdf1352f2') }
        end

        describe '#build_status_url' do
          it { expect(subject.build_status_url).to eq('https://circleci.com/api/v1/project/username/a-project/tree/master?circle-token=b5bb9d8014a0f9b1d61e21e796d78dccdf1352f2') }
        end
      end
    end

    describe '#ci_build_identifier' do
      it { expect(subject.ci_build_identifier).to eq('a-project') }
    end

    describe '#fetch_payload' do
      it { expect(subject.fetch_payload).to be_an_instance_of(CircleCiPayload) }
    end
  end
end
