require 'spec_helper'

describe Message do
  describe "validations" do
    it "should require text" do
      message = Message.new
      message.should_not be_valid
      message.errors[:text].should_not be_nil
      
      message.text = "foo"
      message.should be_valid
    end
  end

  describe "#expires_in" do
    it "returns nil when expires_at is blank" do
      message = Message.new(:expires_at => nil)

      message.expires_in.should be_nil
    end

    it "returns seconds between expires_at and created_at if expires_at is present" do
      now = Time.now
      expiry = now + 1.hour
      message = Message.new(:created_at => now, :expires_at => expiry)

      message.expires_in.should == (expiry - message.created_at)
    end
  end

  describe "#expires_in=" do
    it "sets expires_at to n seconds after the message was created" do
      now = Time.now
      message = Message.new(:created_at => now)
      message.expires_in = 1.hour

      message.created_at.should be
      message.expires_at.should be
      message.expires_at.should == now + 1.hour
    end
  end
end
