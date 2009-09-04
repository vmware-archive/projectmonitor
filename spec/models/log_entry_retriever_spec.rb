require File.dirname(__FILE__) + '/../spec_helper'
require 'hpricot'

describe LogEntryRetriever do
  before(:each) do
    @log_entry_elements = Hpricot(mock_svn_log_xml).search("log/logentry")
    @log_entries = LogEntryRetriever.new(mock_svn_sheller).retrieve
  end

  it "should return an entry for each logentry element in the SVN log" do
    @log_entries.size.should == @log_entry_elements.size
  end

  it "should correctly parse the revision number for each log entry" do
    @log_entries.each do |log_entry|
      @log_entry_elements.search("[@revision=#{log_entry.revision}]").size.should == 1
    end
  end

  it "should correctly parse the time of each log entry" do
    times = @log_entry_elements.search("date").collect { |time_element| Time.parse(time_element.inner_text) }
    @log_entries.each do |log_entry|
      times.select { |time| time == log_entry.date_time }.size.should == 1
    end
  end

  it "should correctly parse the message for each log entry" do
    message_elements = @log_entry_elements.search("msg")
    @log_entries.each do |log_entry|
      message_elements.detect { |element| element.inner_text == log_entry.message }.should_not be_nil
    end
  end

  private

  def mock_svn_sheller
    sheller = mock('sheller')
    sheller.should_receive(:retrieve).and_return(mock_svn_log_xml)
    sheller
  end

  def mock_svn_log_xml
    File.read('test/fixtures/svn_log_examples/svn.xml')
  end

end