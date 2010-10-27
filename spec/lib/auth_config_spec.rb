require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

# todo - there might be a better pattern here....

describe AuthConfig do

  shared_examples_for "prefers environment parameters" do
    before do
      ENV['auth_required'] = 'true'
      ENV['openid_identifier'] = 'google.com'
      ENV['openid_realm'] = 'http://google.com'
      ENV['openid_return_to'] = 'http://google.com/openid/success'
    end

    after do
      ENV['auth_required'] = nil
      ENV['openid_identifier'] = nil
      ENV['openid_realm'] = nil
      ENV['openid_return_to'] = nil
    end

    it "should have an auth_required" do
      AuthConfig.auth_required.should be_true
    end

    describe "with openid" do
      it "should have an openid identifier" do
        AuthConfig.openid_identifier.should == "google.com"
      end

      it "should have an openid realm" do
        AuthConfig.openid_realm.should == "http://google.com"
      end

      it "should have an openid return_to" do
        AuthConfig.openid_return_to.should == "http://google.com/openid/success"
      end

    end
  end

  describe "should prefer environment parameter over yml" do
    it_should_behave_like "prefers environment parameters"
  end

  describe "should use yml configuration" do

    it "should have an auth_required" do
      AuthConfig.auth_required.should == false
    end

    describe "with openid" do
      it "should have an openid identifier" do
        AuthConfig.openid_identifier.should == "example.com"
      end

      it "should have an openid realm" do
        AuthConfig.openid_realm.should == "http://example.com"
      end

      it "should have an openid return_to" do
        AuthConfig.openid_return_to.should == "http://example.com/openid/success"
      end
    end

  end

  describe "should prefer environment parameters over a non-existent file" do
    before do
      AuthConfig.load_from("bad_path")
    end

    after do
      AuthConfig.load_from("#{Rails.root}/config/auth.yml")
    end

    it_should_behave_like "prefers environment parameters"
  end

  describe "should be able to handle a non-existent file" do

    before do
      AuthConfig.load_from("bad_path")
    end

    after do
      AuthConfig.load_from("#{Rails.root}/config/auth.yml")
    end

    it "should have an auth_required" do
      AuthConfig.auth_required.should be_false
    end

    describe "with openid" do
      it "should have an openid identifier" do
        AuthConfig.openid_identifier.should be_nil
      end

      it "should have an openid realm" do
        AuthConfig.openid_realm.should be_nil
      end

      it "should have an openid return_to" do
        AuthConfig.openid_return_to.should be_nil
      end
    end

  end
end
