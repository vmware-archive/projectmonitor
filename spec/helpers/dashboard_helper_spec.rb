require 'spec_helper'

describe DashboardHelper do
  describe "#project_bar_chart" do
    let(:project) { double(:project, last_ten_velocities: last_ten_velocities) }

    context "with one bar" do
      let(:last_ten_velocities) { [1] }

      it "should display one bar at full height" do
        helper.project_bar_chart(project).should include("<span style=\"height: 105%\" />")
      end
    end

    context "with two bars" do
      let(:last_ten_velocities) { [1, 2] }

      it "displays two bars, with heights relative to max" do
        helper.project_bar_chart(project).should include("<span style=\"height: 55%\" />")
        helper.project_bar_chart(project).should include("<span style=\"height: 105%\" />")
      end
    end

    context "with a full history" do
      let(:last_ten_velocities) { [5,8,1,6,10,0,3,7,9,2] }

      it "displays 10 bars with relative heights from oldest to youngest" do
        helper.project_bar_chart(project).scan(/\d+\%/).should == ["25%", "95%", "75%", "35%", "5%", "105%", "65%", "15%", "85%", "55%"]
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
