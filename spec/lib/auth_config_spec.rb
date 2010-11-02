require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

# todo - there might be a better pattern here....

describe AuthConfig do
  # before(:each) do
  #   # moved to spec_helper for use in all tests:
  #     AuthConfig.reset!
  #     AuthConfig.stub(:auth_file_path).and_return(Rails.root.join("spec/fixtures/files/auth.yml"))
  # end

  shared_examples_for "prefers environment parameters" do
    before do
      ENV['AUTH_REQUIRED'] = 'true'
      ENV['OPENID_IDENTIFIER'] = 'google.com'
      ENV['OPENID_REALM'] = 'http://google.com'
      ENV['OPENID_RETURN_TO'] = 'http://google.com/openid/success'
    end

    after do
      ENV['AUTH_REQUIRED'] = nil
      ENV['OPENID_IDENTIFIER'] = nil
      ENV['OPENID_REALM'] = nil
      ENV['OPENID_RETURN_TO'] = nil
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

    it_should_behave_like "prefers environment parameters"
  end

  describe "should be able to handle a non-existent file" do
    before do
      AuthConfig.stub(:auth_file_path).and_return(Rails.root.join("spec/fixtures/files/missing_file.yml"))
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
