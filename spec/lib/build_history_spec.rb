require_relative '../../lib/build_history'

describe BuildHistory do
  describe "#each_build" do
    it "yields control" do
      build_history = BuildHistory.new([double(:status)])
      expect { |b| build_history.each_build(&b) }.to yield_with_args
    end

    it "yields a HistoricalBuild" do
      build_history = BuildHistory.new([double(:status)])

      build_history.each_build do |historical_build|
        historical_build.should be_a HistoricalBuild
      end
    end

    it "creates a HistoricalBuild object for each status" do
      status1 = double(:status1)
      status2 = double(:status2)
      build_history = BuildHistory.new([status1, status2])

      HistoricalBuild.should_receive(:new).with(build_history, status1, 0)
      HistoricalBuild.should_receive(:new).with(build_history, status2, 1)

      build_history.each_build {}
    end
  end
end
