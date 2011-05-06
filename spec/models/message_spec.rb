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

  describe ".active" do
    before do
      @message_no_expiry = Message.create(:text => "hi")
      @message_future_expiry = Message.create(:text => "hello", :expires_at => 1.hour.from_now)
      @message_past_expiry = Message.create(:text => "aloha", :expires_at => 1.hour.ago)
    end

    it "returns messages that do not have an expiration" do
      Message.active.should include(@message_no_expiry)
    end

    it "returns messages with an expiry that haven't yet" do
      Message.active.should include(@message_future_expiry)
    end

    it "doesn't return expired messages" do
      Message.active.should_not include(@message_past_expiry)
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
    
    it "sets expires_at correctly on message creation" do
      message = Message.create(:text => "hi")

      message.expires_at.should_not be


      duration = 1.hour
      message = Message.new(:text => "hi", :expires_in => duration)
      sleep(2)
      message.save

      message.expires_at.should == message.created_at + duration
    end
  end
end
