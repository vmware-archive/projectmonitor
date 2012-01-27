require 'spec_helper'

describe JobManager do

  describe '.jobs_exist?' do
    subject { JobManager.jobs_exist?('project_status') }
    context "when no jobs exist" do
      it { should be_false }
    end

    context "when jobs exist" do
      before do
        StatusFetcher.new.fetch_all
      end
      it { should be_true }
    end
  end

end