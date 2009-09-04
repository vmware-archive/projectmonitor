require 'xml/libxml'

class LogEntryRetriever
  def initialize(svn_sheller = SvnSheller.new)
    @svn_sheller = svn_sheller
  end

  def retrieve
    log_entry_elements_in(xml_svn_log).collect do |log_entry|
      LogEntry.new(revision_for(log_entry), date_for(log_entry), message_for(log_entry))
    end
  rescue Exception
    return []
  end

  private

  def xml_svn_log
    @svn_sheller.retrieve
  end

  def log_entry_elements_in(xml)
    parse(xml).root.find('/log/logentry')
  end

  def parse(xml_string)
    XML::Parser.string(xml_string).parse
  end

  def revision_for(log_entry_element)
    log_entry_element.find_first('@revision').value.to_i
  end

  def date_for(log_entry_element)
    Time.parse(log_entry_element.find_first('date').content).localtime
  end

  def message_for(log_entry_element)
    log_entry_element.find_first('msg').content
  end
end

class SvnSheller
  SVN_URL = 'https://svn.pivotallabs.com/subversion'

  def retrieve
    `svn log #{SVN_URL} --limit=10 . --xml`
  end
end
