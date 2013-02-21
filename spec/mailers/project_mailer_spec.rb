require "spec_helper"

describe ProjectMailer do
  let(:project) { FactoryGirl.create(:project, notification_email: "foo@bar.com", name: "John Doe") }

  before do
    project.statuses << FactoryGirl.build(:project_status, url: "http://www.example.com")
  end

  describe "#build_notification" do
    it "should create an email" do
      a_build_message = ProjectMailer.build_notification(project)

      a_build_message.from.should == ["noreply@pivotallabs.com"]
      a_build_message.to.should == ["foo@bar.com"]
      a_build_message.subject.should include(project.name)
      a_build_message.subject.should include(project.color)
      a_build_message.body.should include(project.name)
      a_build_message.body.should include(project.color)
      a_build_message.body.should include(project.latest_status.published_at)
      a_build_message.body.should include(project.latest_status.url)
    end
  end

  describe "#error_notification" do
    let(:log) { PayloadLogEntry.new(update_method: "a_method", error_type: "an_error_type", error_text: "an_error_text", backtrace: "a_backtrace") }

    it "should create an email" do
      a_build_message = ProjectMailer.error_notification(project, log)

      a_build_message.from.should == ["noreply@pivotallabs.com"]
      a_build_message.to.should == ["foo@bar.com"]
      a_build_message.subject.should include(project.name)
      a_build_message.body.should include(log.update_method)
      a_build_message.body.should include(project.name)
      a_build_message.body.should include(log.error_type)
      a_build_message.body.should include(log.error_text)
      a_build_message.body.should include(log.backtrace)
    end
  end
end
