require 'spec_helper'

describe URLParser do

  class BarBaz < Project
    class << self
      def build_url_from_fields(params)
        "foobar"
      end
      def feed_url_fields
        ["A","B"]
      end
    end
  end
  describe "#initialize" do
    it "should set type and url" do
      u = URLParser.new({foo: "bar"}, BarBaz.name)
      u.type.should == BarBaz
      u.url.should == "foobar"
    end
  end
end
