require 'spec_helper'

describe ::SubGridCollection do

  context "without tile_count" do
    context "should have default tile count" do
      subject { SubGridCollection.new [] }
      its(:size) { should == SubGridCollection::DEFAULT_TILE_COUNT }
    end
  end

  context "with tile_count" do
    let(:collection) { [] }
    let(:null_project) { double(:null_project) }
    before { NullProject.stub(:new).and_return(null_project) }

    subject { SubGridCollection.new collection, tile_count }

    context "greater than passed collection count" do
      let(:tile_count) { 7 }
      its(:size) { should == tile_count }
    end

    context "less than passed collection count" do
      let(:collection) { [1, 2, 3, 4] }
      let(:tile_count) { 2 }
      its(:size) { should == 4 }
      it { should == [1,2,3,4] }
    end

    context "equal to the passed collection count" do
      let(:collection) { [1, 2] }
      let(:tile_count) { 2 }
      its(:size) { should == tile_count }
      it { should == [1,2] }
    end

    context "more_than the passed collection count" do
      let(:collection) { [1, 2] }
      let(:tile_count) { 4 }
      its(:size) { should == tile_count }
      it { should == [1,2,null_project,null_project] }
    end

    context "pads the row when extra slots" do
      let(:collection) { [1,2,3,4,5] }
      let(:tile_count) { 4 }
      its(:size) { should == 8 }
      it { should == [1,2,3,4,5,null_project,null_project,null_project] }
    end

    context "is not present" do
      subject { SubGridCollection.new [] }
      its(:size) { should == SubGridCollection::DEFAULT_TILE_COUNT }
    end

    context "as nil" do
      let(:tile_count) { nil }
      its(:size) { should == SubGridCollection::DEFAULT_TILE_COUNT }
    end
  end

end

