require 'spec_helper'

describe ApplicationHelper do

  describe 'rendering status images' do

    before do
      @now = Time.parse('2008-06-15 12:00')
      Time.stub(:now).and_return(@now)
      @status = ProjectStatus.new
      @status.url = 'http://www.pivotallabs.com/build1'
    end

    describe 'red/green/blue icon' do

      it 'should render the right image for a failed statue' do
        @status.online = true
        @status.success = false
        @status.published_at = @now - 1.hour

        html = helper.historical_status_image(@status)
        html.should == "<a href='http://www.pivotallabs.com/build1'><img src='/assets/red1.png' border='0' /></a>"
      end

      it 'should render the right image for a success statue' do
        @status.online = true
        @status.success = true
        @status.published_at = @now - 1.hour

        html = helper.historical_status_image(@status)
        html.should == "<a href='http://www.pivotallabs.com/build1'><img src='/assets/green1.png' border='0' /></a>"
      end

    end

    describe 'icon size' do

      before do
        @status.online = true
        @status.success = true
      end

      it 'should use size 1 for a build in the last [0, 4) hours'  do
        @status.published_at = @now
        should_use_green_icon(1)

        @status.published_at = @now - 1.hour
        should_use_green_icon(1)

        @status.published_at = @now - 3.5.hours
        should_use_green_icon(1)
      end

      it 'should use size 2 for a build in the last [4, 12) hours'  do
        @status.published_at = @now - 4.hours
        should_use_green_icon(2)

        @status.published_at = @now - 8.hour
        should_use_green_icon(2)

        @status.published_at = @now - 11.5.hours
        should_use_green_icon(2)
      end

      it 'should use size 3 for a build in the last [12, 48) hours'  do
        @status.published_at = @now - 12.hours
        should_use_green_icon(3)

        @status.published_at = @now - 36.hour
        should_use_green_icon(3)

        @status.published_at = @now - 47.5.hours
        should_use_green_icon(3)
      end

      it 'should use size 4 for a build in the last [48, 168) hours'  do
        @status.published_at = @now - 48.hours
        should_use_green_icon(4)

        @status.published_at = @now - 100.hour
        should_use_green_icon(4)

        @status.published_at = @now - 167.5.hours
        should_use_green_icon(4)
      end

      it 'should use size 5 for a build in the last [168, infinity) hours'  do
        @status.published_at = @now - 168.hours
        should_use_green_icon(5)

        @status.published_at = @now - 1000.hour
        should_use_green_icon(5)

        @status.published_at = @now - 100000.hours
        should_use_green_icon(5)
      end

    end

    def should_use_green_icon(number)
      html = helper.historical_status_image(@status)
      html.should == "<a href='http://www.pivotallabs.com/build1'><img src='/assets/green#{number}.png' border='0' /></a>"
    end
  end
  
end