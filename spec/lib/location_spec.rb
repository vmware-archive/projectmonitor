require_relative '../../lib/location'

describe Location do

  describe "#to_s" do
    it "should return the name of the location" do
      l = Location.new "New York"
      l.to_s.should == "New York"

      l = Location.new "Texas"
      l.to_s.should == "Texas"
    end

    it "should return 'Other' if no location was provided" do
      l = Location.new
      l.to_s.should == "Other"
    end
  end

end
