require File.expand_path(File.join(File.dirname(__FILE__),'..','spec_helper'))

describe "UrlRetriever#retrieve_content_at" do
  it "should fetch URIs with query strings" do
    Net::HTTP.stub!(:new).and_return(stub('Net::HTTP stub', :null_object => true, :[] => nil, :code => '200'))
    Net::HTTP::Get.should_receive(:new).with('/path.html?parameter=value').and_return(stub('HTTP::Get stub', :null_object=>true))
    UrlRetriever.new.retrieve_content_at('http://host/path.html?parameter=value')
  end
end
