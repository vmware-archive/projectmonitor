require 'spec_helper'

describe AmazonService do
  describe "#new" do
    it "should create a new EC2 Base" do
      access_key_id = "some id"
      secret_access_key = "some secret"
      AWS::EC2.should_receive(:new).with(
        :access_key_id => access_key_id,
        :secret_access_key => secret_access_key,
        :ssl_ca_file => '/etc/ssl/certs/ca-certificates.crt'
      )

      AmazonService.new(access_key_id, secret_access_key)
    end
  end

  describe "#start_instance" do
    context "the user did not specify an elastic ip" do
      it "should create the amazon instance" do
        instances_mock = mock(:ec2_instances_mock)
        instance_mock = mock(:ec2_instance_mock)
        AWS::EC2.stub(:new).and_return(mock(:ec2, :instances => instances_mock))

        instances_mock.should_receive(:[]).with("cat").and_return(instance_mock)
        instance_mock.should_receive(:start)

        AmazonService.new("a", "b").start_instance("cat")
      end

      it "should cope with if the instance id is invalid" do
        instance_mock = mock(:ec2_instance_mock)
        AWS::EC2.stub_chain(:new, :instances, :[]) { instance_mock }

        instance_mock.stub(:start).and_raise(ArgumentError.new("blah"))

        expect {
          AmazonService.new("a", "b").start_instance("cat")
        }.to raise_error(ArgumentError, "blah")
      end
    end

    context "the user did specify an elastic ip" do
      it "should create the amazon instance" do
        instances_mock = mock(:ec2_instances_mock)
        instance_mock = mock(:ec2_instance_mock)
        AWS::EC2.stub(:new).and_return(mock(:ec2, :instances => instances_mock))

        instances_mock.should_receive(:[]).with("cat").and_return(instance_mock)
        instance_mock.should_receive(:start)
        instance_mock.should_receive(:status).and_return(:running)
        instance_mock.should_receive(:associate_elastic_ip).with(AWS::EC2::ElasticIp.new("123"))

        AmazonService.new("a", "b").start_instance("cat", "123")
      end

      it "should cope with if the instance id is invalid" do
        instance_mock = mock(:ec2_instance_mock)
        AWS::EC2.stub_chain(:new, :instances, :[]) { instance_mock }

        instance_mock.stub(:start).and_raise(ArgumentError.new("blah"))

        expect {
          AmazonService.new("a", "b").start_instance("cat", "123")
        }.to raise_error(ArgumentError, "blah")
      end
    end
  end

  describe "#stop_instance" do
    context "the user did not specify an elastic ip" do
      it "should stop the amazon instance" do
        instances_mock = mock(:ec2_instances_mock)
        instance_mock = mock(:ec2_instance_mock)
        AWS::EC2.stub(:new).and_return(mock(:ec2, :instances => instances_mock))

        instances_mock.should_receive(:[]).with("cat").and_return(instance_mock)
        instance_mock.should_receive(:stop)

        AmazonService.new("a", "b").stop_instance("cat")
      end
    end

    context "the user specified an elastic ip" do
      it "should stop the amazon instance" do
        instances_mock = mock(:ec2_instances_mock)
        instance_mock = mock(:ec2_instance_mock)
        AWS::EC2.stub(:new).and_return(mock(:ec2, :instances => instances_mock))

        instances_mock.should_receive(:[]).with("cat").and_return(instance_mock)
        instance_mock.should_receive(:stop)
        instance_mock.should_receive(:disassociate_elastic_ip)

        AmazonService.new("a", "b").stop_instance("cat", "123")
      end
    end
  end

  describe ".schedule" do
    before(:each) do
      @time = DateTime.parse("Tue, 09 Aug 2011 17:07:41 -0700")
      @start_project = Project.create!(:name => "my_start_project", :feed_url => "http://foo.bar.com/baz.rss",
                                       :ec2_tuesday => true, :ec2_start_time => (@time - 3.minutes).strftime('%H:%M'),
                                       :ec2_access_key_id => "some id", :ec2_secret_access_key => "some secret",
                                       :ec2_instance_id => "some instance")

      @end_project = Project.create!(:name => "my_end_project", :feed_url => "http://foo.bar.com/baz.rss",
                                     :ec2_tuesday => true, :ec2_end_time => (@time + 5.hours - 1.minute).strftime('%H:%M'),
                                     :ec2_access_key_id => "some end id", :ec2_secret_access_key => "some end secret",
                                     :ec2_instance_id => "some end instance")

      @instance_mock = mock(:instance_mock, :start => nil, :stop => nil, :[] => @instance_mock)
    end

    it "should not end any project of a time not in the last 5 minutes but for the correct day" do
      AWS::EC2.should_not_receive(:new)

      AmazonService.schedule(@time - 6.minutes)
    end


    context "when starting a project" do
      before(:each) do
        AWS::EC2.stub_chain(:new, :instances, :[]).and_return(@instance_mock)
      end

      it "should create the amazon ec2 object" do
        AWS::EC2.should_receive(:new).with(:access_key_id => "some id", :secret_access_key => "some secret", :ssl_ca_file => '/etc/ssl/certs/ca-certificates.crt')

        AmazonService.schedule(@time)
      end

      it "get the correct instance" do
        AWS::EC2.stub_chain(:new, :instances).and_return(@instance_mock)
        @instance_mock.should_receive(:[]).with("some instance").and_return(mock(:instance, :start => nil))

        AmazonService.schedule(@time)
      end

      it "should start any projects which are staring in the last 5 minutes for that day" do
        @instance_mock.should_receive(:start)

        AmazonService.schedule(@time)
      end

      it "should not start the project of a different day" do
        @start_project.update_attribute(:ec2_tuesday, false)
        AWS::EC2.should_not_receive(:new)

        AmazonService.schedule(@time)
      end
    end

    context "when ending a project" do
      before(:each) do
        AWS::EC2.stub_chain(:new, :instances, :[]).and_return(@instance_mock)
        @time += 5.hours
      end

      it "should create the amazon ec2 object" do
        AWS::EC2.should_receive(:new).with(:access_key_id => "some end id", :secret_access_key => "some end secret", :ssl_ca_file => '/etc/ssl/certs/ca-certificates.crt')

        AmazonService.schedule(@time)
      end

      it "get the correct instance" do
        AWS::EC2.stub_chain(:new, :instances).and_return(@instance_mock)
        @instance_mock.should_receive(:[]).with("some end instance").and_return(mock(:instance, :stop => nil))

        AmazonService.schedule(@time)
      end

      it "should end any projects which are ending in the last 5 minutes for that day" do
        @instance_mock.should_receive(:stop)

        AmazonService.schedule(@time)
      end

      it "should not end the project of a different day" do
        @end_project.update_attribute(:ec2_tuesday, false)
        @instance_mock.should_not_receive(:stop)

        AmazonService.schedule(@time)
      end
    end
  end
end