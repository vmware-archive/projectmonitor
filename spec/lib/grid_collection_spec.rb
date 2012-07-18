require 'spec_helper'

describe ::GridCollection do
  context "without tile count" do
    subject { GridCollection.new collection }

    context "instantiated with an empty collection" do
      let(:collection) { [] }

      its(:count) { should == 15}

      it "should make all the elements NullProject" do
        subject.all?{ |element| element.is_a? NullProject }.should be_true
      end
    end

    context "instantiated with a collection of size < 15" do
      let(:collection) { [1,2,3] }

      its(:count) { should == 15}

      it "should pad the collection with NullProject objects" do
        subject.select{ |element| element.is_a? NullProject }.count.should == 12
        subject[0...3].should == collection
      end
    end

    context "instantiated with a collection of size = 15" do
      let(:collection) { (0...15).to_a }

      its(:count) { should == 15}

      it "should pad the collection with NullProject objects" do
        subject.select{ |element| element.is_a? NullProject }.count.should == 0
        subject.should == collection
      end
    end

    context "instantiated with a collection of size > 15 AND < 24" do
      let(:collection) { (0...16).to_a }

      its(:count) { should == 24}

      it "should pad the collection with NullProject objects" do
        subject.select{ |element| element.is_a? NullProject }.count.should == 8
        subject[0...16].should == collection
      end
    end

    context "instantiated with a collection of size = 24" do
      let(:collection) { (0...24).to_a }

      its(:count) { should == 24}

      it "should pad the collection with NullProject objects" do
        subject.select{ |element| element.is_a? NullProject }.count.should == 0
        subject.should == collection
      end
    end


    context "instantiated with a collection of size > 24 AND < 48" do
      let(:collection) { (0...25).to_a }

      its(:count) { should == 48}

      it "should pad the collection with NullProject objects" do
        subject.select{ |element| element.is_a? NullProject }.count.should == (48 - 25)
        subject[0...25].should == collection
      end
    end

    context "instantiated with a collection of size = 48" do
      let(:collection) { (0...48).to_a }

      its(:count) { should == 48}

      it "should pad the collection with NullProject objects" do
        subject.select{ |element| element.is_a? NullProject }.count.should == 0
        subject.should == collection
      end
    end

    context "instantiated with a collection of size > 48 AND < 63" do
      let(:collection) { (0...49).to_a }

      its(:count) { should == 63}

      it "should pad the collection with NullProject objects" do
        subject.select{ |element| element.is_a? NullProject }.count.should == (63 - 49)
        subject[0...49].should == collection
      end
    end

    context "instantiated with a collection of size = 63" do
      let(:collection) { (0...63).to_a }

      its(:count) { should == 63}

      it "should pad the collection with NullProject objects" do
        subject.select{ |element| element.is_a? NullProject }.count.should == 0
        subject.should == collection
      end
    end

    context "instantiated with a collection size > 63" do
      let(:collection) { (0...100).to_a }

      specify { expect { subject }.to raise_exception(ArgumentError, "We never anticipated more than 63 projects. Sorry.") }
    end
  end

  context "with tile_count" do
    let(:collection) { [] }
    subject { GridCollection.new collection, tile_count }

    context "one row" do
      context "greater than passed collection count" do
        let(:tile_count) { 7 }
        its(:size) { should == tile_count }
      end

      context "less than passed collection count" do
        let(:collection) { [1, 2, 3, 4] }
        let(:tile_count) { 2 }
        its(:size) { should == tile_count }
        it { should == [1,2] }
      end

      context "equal to the passed collection count" do
        let(:collection) { [1, 2] }
        let(:tile_count) { 2 }
        its(:size) { should == tile_count }
        it { should == [1,2] }
      end

      context "more_than the passed collection count" do
        let(:null_project) { double(:null_project) }
        let(:collection) { [1, 2] }
        let(:tile_count) { 4 }
        before { NullProject.stub(:new).and_return(null_project) }
        its(:size) { should == tile_count }
        it { should == [1,2,null_project,null_project] }
      end
    end

    context "more than one row" do
      context "pads the row when extra slots" do
        let(:collection) { [1,2,3,4,5] }
        let(:tile_count) { 4 }
        its(:size) { should == 4 }
        it { should == [1,2,3,4] }
      end
    end

    context "is not present" do
      subject { GridCollection.new [] }
      its(:size) { should == GridCollection::LIMITS.first }
    end

    context "as nil" do
      let(:tile_count) { nil }
      its(:size) { should == GridCollection::LIMITS.first }
    end
  end

end
