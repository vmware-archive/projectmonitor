require File.dirname(__FILE__) + '/../spec_helper'

describe PulseNotifier do
  before(:each) do
    ActionMailer::Base.deliveries = []
  end

  describe "#send_red_over_one_day_notifications" do
    describe "with projects that have been red for over one day" do
      before(:each) do
        @long_red_project = Project.create!(:name => "Long red", :feed_url => "http://long/red.rss")
        @long_red_project.statuses.create!(:online => true, :success => false, :published_at => Clock.now)

        @long_red_disabled_project = Project.create!(:enabled => false, :name => "Long red disabled", :feed_url => "http://long_disabled/red.rss")
        @long_red_disabled_project.statuses.create!(:online => true, :success => false, :published_at => Clock.now)

        Clock.tick 2.days

        @short_red_project = Project.create!(:name => "Short red", :feed_url => "http://short/red.rss")
        @short_red_project.statuses.create!(:online => true, :success => false, :published_at => Clock.now)

        @green_project = Project.create!(:name => "Green", :feed_url => "http://green.rss")
        @green_project.statuses.create!(:online => true, :success => true, :published_at => Clock.now)

        @offline_project = Project.create!(:name => "Offline", :feed_url => "http://off/line.rss")
        @offline_project.statuses.create!(:online => false, :published_at => Clock.now)

        PulseNotifier.send_red_over_one_day_notifications
      end

      it "should send one email" do
        ActionMailer::Base.deliveries.size.should == 1
      end

      it "should include the names of only projects that have been red for over one day in the email" do
        mail = ActionMailer::Base.deliveries.first
        mail.body.should include(@long_red_project.name)
        mail.body.should_not include(@short_red_project.name)
        mail.body.should_not include(@green_project.name)
        mail.body.should_not include(@offline_project.name)
      end

      it "should send the email to the recipients specified by the environment" do
        mail = ActionMailer::Base.deliveries.first
        mail.to.should == RED_NOTIFICATION_EMAILS
      end

      it "should not send emails for disabled projects" do
        mail = ActionMailer::Base.deliveries.first
        mail.body.should_not include(@long_red_disabled_project.name)
      end
    end

    describe "with no projects that have been red for over one day" do
      before(:each) do
        Project.find(:all).each do |project|
          project.statuses.create!(:online => true, :success => true, :published_at => Clock.now)
        end
        PulseNotifier.send_red_over_one_day_notifications
      end

      it "should not send an email" do
        ActionMailer::Base.deliveries.should be_empty
      end
    end
  end
end
