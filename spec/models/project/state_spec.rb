require 'spec_helper'

describe Project::State do
  describe '#failure?' do
    context "when the project is offline" do
      subject { described_class.new(online: false, success: nil) }
      it { should_not be_failure }
    end

    context "when the project is online" do
      context "and its latest build is failing" do
        subject { described_class.new(online: true, success: false) }
        it { should be_failure }
      end

      context "and its latest build is successful" do
        subject { described_class.new(online: true, success: true) }
        it { should_not be_failure }
      end
    end
  end

  describe '#success?' do
    context "when the project is offline" do
      subject { described_class.new(online: false, success: nil) }
      it { should_not be_success }
    end

    context "when the project is online" do
      context "and its latest build succeeded" do
        subject { described_class.new(online: true, success: true) }
        it { should be_success }
      end

      context "and its latest build failed" do
        subject { described_class.new(online: true, success: false) }
        it { should_not be_success }
      end
    end
  end

  describe '#indeterminate?' do
    context "when the project is offline" do
      subject { described_class.new(online: false, success: nil) }
      it { should_not be_indeterminate }
    end

    context "when the project is online" do
      context "and there are no builds" do
        subject { described_class.new(online: true, success: nil) }
        it { should be_indeterminate }
      end

      context "and its latest build failed" do
        subject { described_class.new(online: true, success: false) }
        it { should_not be_indeterminate }
      end
    end
  end

  describe '#offline?' do
    context "when the project is offline" do
      subject { described_class.new(online: false, success: nil) }
      it { should be_offline }
    end

    context "when the project is online" do
      subject { described_class.new(online: true, success: nil) }
      it { should be_online }
    end
  end

  describe "#to_s" do
    context "when project is red" do
      subject { described_class.new(online: true, success: false) }
      its(:to_s) { should == "failure" }
    end

    context "when project is green" do
      subject { described_class.new(online: true, success: true) }
      its(:to_s) { should == "success" }
    end

    context "when project is yellow" do
      subject { described_class.new(online: true, success: nil) }
      its(:to_s) { should == "indeterminate" }
    end

    context "when project none of the statuses" do
      subject { described_class.new(online: false, success: nil) }
      its(:to_s) { should == "offline" }
    end
  end

  describe "#color" do
    context "when project is red" do
      subject { described_class.new(online: true, success: false).color }
      it { should == "red" }
    end

    context "when project is green" do
      subject { described_class.new(online: true, success: true).color }
      it { should == "green" }
    end

    context "when project is yellow" do
      subject { described_class.new(online: true, success: nil).color }
      it { should == "yellow" }
    end

    context "when project none of the statuses" do
      subject { described_class.new(online: false, success: nil).color }
      it { should == "white" }
    end
  end
end