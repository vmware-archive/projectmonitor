require File.expand_path(File.join(File.dirname(__FILE__),'..','spec_helper'))

describe Message do

  it "should require text" do
    message = Message.new
    message.should_not be_valid
    message.errors.on(:text).should_not be_nil
    
    message.text = "foo"
    message.should be_valid
  end


end