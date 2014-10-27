require 'spec_helper'

describe Project::State, :type => :model do
  describe '#failure?' do
    context "when the project is offline" do
      subject { described_class.new(online: false, success: nil) }
      it { is_expected.not_to be_failure }
    end

    context "when the project is online" do
      context "and its latest build is failing" do
        subject { described_class.new(online: true, success: false) }
        it { is_expected.to be_failure }
      end

      context "and its latest build is successful" do
        subject { described_class.new(online: true, success: true) }
        it { is_expected.not_to be_failure }
      end
    end
  end

  describe '#success?' do
    context "when the project is offline" do
      subject { described_class.new(online: false, success: nil) }
      it { is_expected.not_to be_success }
    end

    context "when the project is online" do
      context "and its latest build succeeded" do
        subject { described_class.new(online: true, success: true) }
        it { is_expected.to be_success }
      end

      context "and its latest build failed" do
        subject { described_class.new(online: true, success: false) }
        it { is_expected.not_to be_success }
      end
    end
  end

  describe '#indeterminate?' do
    context "when the project is offline" do
      subject { described_class.new(online: false, success: nil) }
      it { is_expected.not_to be_indeterminate }
    end

    context "when the project is online" do
      context "and there are no builds" do
        subject { described_class.new(online: true, success: nil) }
        it { is_expected.to be_indeterminate }
      end

      context "and its latest build failed" do
        subject { described_class.new(online: true, success: false) }
        it { is_expected.not_to be_indeterminate }
      end
    end
  end

  describe '#offline?' do
    context "when the project is offline" do
      subject { described_class.new(online: false, success: nil) }
      it { is_expected.to be_offline }
    end

    context "when the project is online" do
      subject { described_class.new(online: true, success: nil) }
      it { is_expected.to be_online }
    end
  end

  describe "#to_s" do
    context "when project is red" do
      subject { described_class.new(online: true, success: false) }

      describe '#to_s' do
        subject { super().to_s }
        it { is_expected.to eq("failure") }
      end
    end

    context "when project is green" do
      subject { described_class.new(online: true, success: true) }

      describe '#to_s' do
        subject { super().to_s }
        it { is_expected.to eq("success") }
      end
    end

    context "when project is yellow" do
      subject { described_class.new(online: true, success: nil) }

      describe '#to_s' do
        subject { super().to_s }
        it { is_expected.to eq("indeterminate") }
      end
    end

    context "when project none of the statuses" do
      subject { described_class.new(online: false, success: nil) }

      describe '#to_s' do
        subject { super().to_s }
        it { is_expected.to eq("offline") }
      end
    end
  end

  describe "#color" do
    context "when project is red" do
      subject { described_class.new(online: true, success: false).color }
      it { is_expected.to eq("red") }
    end

    context "when project is green" do
      subject { described_class.new(online: true, success: true).color }
      it { is_expected.to eq("green") }
    end

    context "when project is yellow" do
      subject { described_class.new(online: true, success: nil).color }
      it { is_expected.to eq("yellow") }
    end

    context "when project none of the statuses" do
      subject { described_class.new(online: false, success: nil).color }
      it { is_expected.to eq("white") }
    end
  end
end