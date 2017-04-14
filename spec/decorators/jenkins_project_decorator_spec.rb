require 'spec_helper'

describe JenkinsProjectDecorator do

  describe '#current_build_url' do
    subject { project.decorate.current_build_url }

    let(:project) { JenkinsProject.new(webhooks_enabled: webhooks_enabled,
                                       ci_base_url: ci_base_url) }
    let(:ci_base_url) { "http://example.com/ci_base_url" }
    let(:parsed_url)  { "http://example.com/parsed_url" }

    before do
      project.parsed_url = parsed_url
    end

    context "webhooks are enabled" do
      let(:webhooks_enabled) { true }

      it { is_expected.to eq(parsed_url) }
    end

    context "webhooks are disabled" do
      let(:webhooks_enabled) { false }

      it { is_expected.to eq(ci_base_url) }
    end
  end

end
