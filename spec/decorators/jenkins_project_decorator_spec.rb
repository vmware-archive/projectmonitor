require 'spec_helper'

describe JenkinsProjectDecorator do

  describe '#current_build_url' do
    subject { project.decorate.current_build_url }

    let(:project) { JenkinsProject.new(webhooks_enabled: webhooks_enabled,
                                       jenkins_base_url: jenkins_base_url) }
    let(:jenkins_base_url) { double(:jenkins_base_url) }
    let(:parsed_url) { double(:parsed_url) }

    before do
      project.parsed_url = parsed_url
    end

    context "webhooks are enabled" do
      let(:webhooks_enabled) { true }

      it { should == parsed_url }
    end

    context "webhooks are disabled" do
      let(:webhooks_enabled) { false }

      it { should == jenkins_base_url }
    end
  end

end
