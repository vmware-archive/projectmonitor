require 'spec_helper'

describe DashboardHelper do
  describe "#tracker_histogram" do
    let(:project) { double(:project, last_ten_velocities: last_ten_velocities) }
    let(:last_ten_velocities) { [5,8,1,6,10,0,3,7,9,2] }

    describe "regarding bar height" do
      it "displays 10 bars with relative heights from oldest to youngest" do
        helper.tracker_histogram(project).scan(/\d+\%/).should == %w(25% 95% 75% 35% 5% 105% 65% 15% 85% 55%)
      end
    end

    describe "regarding opacity" do
      it "displays the bars from most transparent to least transparent" do
        helper.tracker_histogram(project).scan(/[01]\.\d{1,2}/).should == %w(0.37 0.44 0.51 0.58 0.65 0.72 0.79 0.86 0.93 1.0)
      end

      context "when < 10 velocities" do
        let(:last_ten_velocities) { [5,8,1,6,10] }

        it "displays the bars with adjusted opacity increments" do
          helper.tracker_histogram(project).scan(/[01]\.\d{1,2}/).should == %w(0.44 0.58 0.72 0.86 1.0)
        end
      end
    end
  end

  describe "#status_count_for" do
    subject  { helper.status_count_for(number) }

    before do
      helper.status_count_for(number) do |status|
        status
      end
    end

    context "when a number is passed" do
      context "when 15 is passed" do
        let(:number) { 15 }
        it { should == 8 }
      end

      context "when 24 is passed" do
        let(:number) { 24 }
        it { should == 8 }
      end

      context "when 48 is passed" do
        let(:number) { 48 }
        it { should == 6 }
      end

      context "when 63 is passed" do
        let(:number) { 63 }
        it { should == 5 }
      end
    end

    context "when a number is not passed" do
      let(:number) { nil }
      it { should == 6 }
    end
  end

  describe "#tile_for" do
    subject { helper.tile_for @tile_obj }

    context "when nil" do
      it { should be_nil }
    end

    context "when a location" do
      before do
        @tile_obj = Location.new("Georgia")
      end
      it { should == @tile_obj }
    end

    context "when a ProjectDecorator" do
      before do
        ProjectDecorator.stub(:new).and_return(:project_decorator)
        @tile_obj = Project.new
      end
      it { should == :project_decorator }
    end

  end
end
