require_relative '../../lib/historical_build'

describe HistoricalBuild do
  let(:build_history) { double(:build_history, box_opacity_step: 0.05, indicator_opacity_step: 0.1) }

  describe "#box_opacity" do
    describe "calculates an opacity based on index and box_opacity_step" do
      subject { HistoricalBuild.new(build_history, nil, index).box_opacity }

      context "when index = 0" do
        let(:index) { 0 }
        it { is_expected.to eq(1.0) }
      end

      context "when index = 1" do
        let(:index) { 1 }
        it { is_expected.to eq(0.95) }
      end

      context "when index = 5" do
        let(:index) { 5 }
        it { is_expected.to eq(0.75) }
      end
    end
  end

  describe "#indicator_opacity" do
    describe "calculates an opacity to give an overall opacity based on index and indicator_opacity_step" do
      subject { HistoricalBuild.new(build_history, nil, index).indicator_opacity }

      context "when index = 0" do
        let(:index) { 0 }
        it { is_expected.to eq(1.0) }
      end

      context "when index = 1" do
        let(:index) { 1 }
        it { is_expected.to eq(0.947) }
      end

      context "when index = 5" do
        let(:index) { 5 }
        it { is_expected.to eq(0.667) }
      end
    end
  end
end
