require 'spec_helper'

describe DashboardHelper do
  context "#grid_class" do
    subject { helper.grid_class }

    context "when there are no projects" do
      it { should == "grid_4" }
    end

    context "when there are 15 projects" do
      before do
        @projects = stub(GridCollection, :size => 15)
      end
      it { should == "grid_4" }
    end

    context "when there are 24 projects" do
      before do
        @projects = stub(GridCollection, :size => 24)
      end
      it { should == "grid_3" }
    end
  end
end
