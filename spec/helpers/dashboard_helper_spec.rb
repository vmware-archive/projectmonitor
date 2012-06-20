require 'spec_helper'

describe DashboardHelper do
  context "#tile_for" do
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

    context "#status_count_for" do
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
  end
end
