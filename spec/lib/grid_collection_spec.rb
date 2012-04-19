require_relative '../../lib/grid_collection'

describe ::GridCollection do
  context "without tile count" do
    subject { GridCollection.new collection }

    context "instantiated with an empty collection" do
      let(:collection) { [] }

      its(:count) { should == 15}

      it "should make all the elements nil" do
        subject.all?(&:nil?).should be_true
      end
    end

    context "instantiated with a collection of size < 15" do
      let(:collection) { [1,2,3] }

      its(:count) { should == 15}

      it "should pad the collection with nil objects" do
        subject.select(&:nil?).count.should == 12
        subject[0...3].should == collection
      end
    end

    context "instantiated with a collection of size = 15" do
      let(:collection) { (0...15).to_a }

      its(:count) { should == 15}

      it "should pad the collection with nil objects" do
        subject.select(&:nil?).count.should == 0
        subject.should == collection
      end
    end

    context "instantiated with a collection of size > 15 AND < 24" do
      let(:collection) { (0...16).to_a }

      its(:count) { should == 24}

      it "should pad the collection with nil objects" do
        subject.select(&:nil?).count.should == 8
        subject[0...16].should == collection
      end
    end

    context "instantiated with a collection of size = 24" do
      let(:collection) { (0...24).to_a }

      its(:count) { should == 24}

      it "should pad the collection with nil objects" do
        subject.select(&:nil?).count.should == 0
        subject.should == collection
      end
    end


    context "instantiated with a collection of size > 24 AND < 48" do
      let(:collection) { (0...25).to_a }

      its(:count) { should == 48}

      it "should pad the collection with nil objects" do
        subject.select(&:nil?).count.should == (48 - 25)
        subject[0...25].should == collection
      end
    end

    context "instantiated with a collection of size = 48" do
      let(:collection) { (0...48).to_a }

      its(:count) { should == 48}

      it "should pad the collection with nil objects" do
        subject.select(&:nil?).count.should == 0
        subject.should == collection
      end
    end

    context "instantiated with a collection size > 48" do
      let(:collection) { (0...50).to_a }

      specify { expect { subject }.to raise_exception(ArgumentError, "We never anticipated more than 48 projects. Sorry.") }
    end
  end

  context "with tile_count" do
    subject { GridCollection.new [], tile_count }
    context "when present" do
      let(:tile_count) { 24 }
      its(:size) { should == tile_count }
    end

    context "when not present" do
      subject { GridCollection.new [] }
      its(:size) { should == GridCollection::LIMITS.first }
    end

    context "when nil" do
      let(:tile_count) { nil }
      its(:size) { should == GridCollection::LIMITS.first }
    end
  end
end
