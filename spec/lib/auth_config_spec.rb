require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

# todo - there might be a better pattern here....

describe AuthConfig do
  # before(:each) do
  #   # moved to spec_helper for use in all tests:
  #     AuthConfig.reset!
  #     AuthConfig.stub(:auth_file_path).and_return(Rails.root.join("spec/fixtures/files/auth-false.yml"))
  # end

  describe "should prefer environment variables over auth.yml" do
    before do
      ENV['AUTH_REQUIRED'] = 'openid for reals'
      ENV['OPENID_IDENTIFIER'] = 'google.com'
      ENV['OPENID_REALM'] = 'http://google.com'
      ENV['OPENID_RETURN_TO'] = 'http://google.com/openid/success'
      AuthConfig.stub(:auth_file_path).and_return(Rails.root.join("spec/fixtures/files/auth-openid.yml"))
    end

    after do
      ENV['AUTH_REQUIRED'] = nil
      ENV['OPENID_IDENTIFIER'] = nil
      ENV['OPENID_REALM'] = nil
      ENV['OPENID_RETURN_TO'] = nil
    end

    it "should have an auth_required" do
      AuthConfig.auth_required.should == "openid for reals"
    end

    it "should have openid settings" do
      AuthConfig.openid_identifier.should == "google.com"
      AuthConfig.openid_realm.should == "http://google.com"
      AuthConfig.openid_return_to.should == "http://google.com/openid/success"
    end
  end

  describe "should use auth.yml configuration" do
    describe "for openid" do
      before(:each) do
        AuthConfig.stub(:auth_file_path).and_return(Rails.root.join("spec/fixtures/files/auth-openid.yml"))
      end
      it "should have an auth_required" do
        AuthConfig.auth_required.should == "openid"
      end

      it "should have openid settings" do
        AuthConfig.openid_identifier.should == "example.com"
        AuthConfig.openid_realm.should == "http://example.com"
        AuthConfig.openid_return_to.should == "http://example.com/openid/success"
      end
    end

    describe "for local passwords" do
      before(:each) do
        AuthConfig.stub(:auth_file_path).and_return(Rails.root.join("spec/fixtures/files/auth-password.yml"))
      end
      it "should have an auth_required" do
        AuthConfig.auth_required.should == "password"
      end

      it "should have password settings" do
        AuthConfig.rest_auth_site_key.should == "replace-this-key-with-yours"
        AuthConfig.rest_auth_digest_stretches.should == 10
      end
    end
  end

  describe "should be able to handle a non-existent file" do
    before do
      ENV['AUTH_REQUIRED'] = nil
      ENV['OPENID_IDENTIFIER'] = nil
      ENV['OPENID_REALM'] = nil
      ENV['OPENID_RETURN_TO'] = nil
      AuthConfig.stub(:auth_file_path).and_return(Rails.root.join("spec/fixtures/files/missing_file.yml"))
    end

    it "should have an auth_required" do
      AuthConfig.auth_required.should be_false
    end

    it "should default local auth settings to nil" do
      AuthConfig.rest_auth_site_key.should be_nil
      AuthConfig.rest_auth_digest_stretches.should be_nil
    end

    it "should default openid settings to nil" do
      AuthConfig.openid_identifier.should be_nil
      AuthConfig.openid_realm.should be_nil
      AuthConfig.openid_return_to.should be_nil
    end
  end
end
