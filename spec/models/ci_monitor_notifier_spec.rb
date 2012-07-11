require 'spec_helper'

describe CiMonitorNotifier do
  before do
    ActionMailer::Base.deliveries = []
  end

  describe "#send_red_over_one_day_notifications" do
    describe "with projects that have been red for over one day" do
      before do
        @long_red_project = FactoryGirl.create(:project, :name => "Long red")
        @long_red_project.statuses.create!(:online => true, :success => false, :published_at => Clock.now)

        @long_red_disabled_project = FactoryGirl.create(:project, :enabled => false, :name => "Long red disabled")
        @long_red_disabled_project.statuses.create!(:online => true, :success => false, :published_at => Clock.now)

        Clock.tick 2.days

        @short_red_project = FactoryGirl.create(:project, :name => "Short red")
        @short_red_project.statuses.create!(:online => true, :success => false, :published_at => Clock.now)

        @green_project = FactoryGirl.create(:project, :name => "Green")
        @green_project.statuses.create!(:online => true, :success => true, :published_at => Clock.now)

        @offline_project = FactoryGirl.create(:project, :name => "Offline")
        @offline_project.statuses.create!(:online => false, :published_at => Clock.now)

        CiMonitorNotifier.send_red_over_one_day_notifications
      end

      it "should send one email" do
        ActionMailer::Base.deliveries.size.should == 1
      end

      it "should include the names of only projects that have been red for over one day in the email" do
        mail = ActionMailer::Base.deliveries.first
        mail.body.encoded.should include(@long_red_project.name)
        mail.body.encoded.should_not include(@short_red_project.name)
        mail.body.encoded.should_not include(@green_project.name)
        mail.body.encoded.should_not include(@offline_project.name)
      end

      it "should send the email to the recipients specified by the environment" do
        mail = ActionMailer::Base.deliveries.first
        mail.to.should == RED_NOTIFICATION_EMAILS
      end

      it "should not send emails for disabled projects" do
        mail = ActionMailer::Base.deliveries.first
        mail.body.encoded.should_not include(@long_red_disabled_project.name)
      end
    end

    describe "with no projects that have been red for over one day" do
      before do
        Project.find(:all).each do |project|
          project.statuses.create!(:online => true, :success => true, :published_at => Clock.now)
        end
        CiMonitorNotifier.send_red_over_one_day_notifications
      end

      it "should not send an email" do
        ActionMailer::Base.deliveries.should be_empty
      end
    end
  end
end
