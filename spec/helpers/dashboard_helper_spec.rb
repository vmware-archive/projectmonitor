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
  end
end
