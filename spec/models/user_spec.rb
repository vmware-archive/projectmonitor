require 'spec_helper'

describe User do
  fixtures :users

  describe 'being created' do
    before do
      @user = nil
      @creating_user = lambda do
        @user = create_user
        violated "#{@user.errors.full_messages.to_sentence}" if @user.new_record?
      end
    end

    it 'increments User#count' do
      @creating_user.should change(User, :count).by(1)
    end
  end

  it 'requires login' do
    lambda do
      u = create_user(:login => nil)
      u.errors[:name].should_not be_nil
    end.should_not change(User, :count)
  end

  describe 'allows legitimate logins:' do
    ['123', '1234567890_234567890_234567890_234567890',
     'hello.-_there@funnychar.com'].each do |login_str|
      it "should work for '#{login_str}'" do
        lambda do
          u = create_user(:login => login_str)
          u.errors[:name].should be_empty
        end.should change(User, :count).by(1)
      end
    end
  end
  describe 'disallows illegitimate logins:' do
    ['12', '1234567890_234567890_234567890_234567890_', "tab\t", "newline\n",
     "Iñtërnâtiônàlizætiøn hasn't happened to ruby 1.8 yet",
     'semicolon;', 'quote"', 'tick\'', 'backtick`', 'percent%', 'plus+', 'space '].each do |login_str|
      it "'#{login_str}'" do
        lambda do
          u = create_user(:login => login_str)
          u.errors[:name].should_not be_nil
        end.should_not change(User, :count)
      end
    end
  end

  it 'requires password' do
    lambda do
      u = create_user(:password => nil)
      u.errors[:name].should_not be_nil
    end.should_not change(User, :count)
  end

  it 'requires password confirmation' do
    lambda do
      u = create_user(:password_confirmation => nil)
      u.errors[:name].should_not be_nil
    end.should_not change(User, :count)
  end

  it 'requires email' do
    lambda do
      u = create_user(:email => nil)
      u.errors[:name].should_not be_nil
    end.should_not change(User, :count)
  end

  describe 'allows legitimate emails:' do
    ['foo@bar.com', 'foo@newskool-tld.museum', 'foo@twoletter-tld.de', 'foo@nonexistant-tld.qq',
     'r@a.wk', '1234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890@gmail.com',
     'hello.-_there@funnychar.com', 'uucp%addr@gmail.com', 'hello+routing-str@gmail.com',
     'domain@can.haz.many.sub.doma.in', 'student.name@university.edu'
    ].each do |email_str|
      it "should work for '#{email_str}'" do
        lambda do
          u = create_user(:email => email_str)
          u.errors[:email].should be_empty
        end.should change(User, :count).by(1)
      end
    end
  end
  describe 'disallows illegitimate emails' do
    ['!!@nobadchars.com', 'foo@no-rep-dots..com', 'foo@badtld.xxx', 'foo@toolongtld.abcdefg',
     'Iñtërnâtiônàlizætiøn@hasnt.happened.to.email', 'need.domain.and.tld@de', "tab\t", "newline\n",
     'r@.wk', '1234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890@gmail2.com',
     # these are technically allowed but not seen in practice:
     'uucp!addr@gmail.com', 'semicolon;@gmail.com', 'quote"@gmail.com', 'tick\'@gmail.com', 'backtick`@gmail.com', 'space @gmail.com', 'bracket<@gmail.com', 'bracket>@gmail.com'
    ].each do |email_str|
      it "'#{email_str}'" do
        lambda do
          u = create_user(:email => email_str)
          u.errors[:name].should_not be_nil
        end.should_not change(User, :count)
      end
    end
  end

  describe 'allows legitimate names:' do
    ['Andre The Giant (7\'4", 520 lb.) -- has a posse',
     '', '1234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890',
    ].each do |name_str|
      it "should work for '#{name_str}'" do
        lambda do
          u = create_user(:name => name_str)
          u.errors[:name].should be_empty
        end.should change(User, :count).by(1)
      end
    end
  end
  describe "disallows illegitimate names" do
    ["tab\t", "newline\n",
     '1234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_',
    ].each do |name_str|
      it "'#{name_str}'" do
        lambda do
          u = create_user(:name => name_str)
          u.errors[:name].should_not be_nil
        end.should_not change(User, :count)
      end
    end
  end

  it 'resets password' do
    users(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    User.authenticate('quentin', 'new password').should == users(:quentin)
  end

  it "doesn't authenticate user with bad password" do
    User.authenticate('quentin', 'invalid_password').should be_nil
  end

  describe "find or create from google openid fetch response" do

    it "should generate name/email from the fetch response" do
      fetch_response = mock()
      fetch_response.should_receive(:get_single).once.with('http://axschema.org/contact/email').and_return("wilma@example.com")
      fetch_response.should_receive(:get_single).once.with('http://axschema.org/namePerson/first').and_return("Wilma")
      fetch_response.should_receive(:get_single).once.with('http://axschema.org/namePerson/last').and_return("Flintstone")

      lambda {
        user = User.find_or_create_from_google_openid(fetch_response)
        user.login.should == "wilma"
        user.name.should == "Wilma Flintstone"
        user.email.should == "wilma@example.com"
        user.should be_valid
      }.should change(User, :count).by(1)
    end

    it "handle blank names" do
      fetch_response = mock()
      fetch_response.should_receive(:get_single).once.with('http://axschema.org/contact/email').and_return("wilma@example.com")
      fetch_response.should_receive(:get_single).once.with('http://axschema.org/namePerson/first').and_return("")
      fetch_response.should_receive(:get_single).once.with('http://axschema.org/namePerson/last').and_return("")

      lambda {
        user = User.find_or_create_from_google_openid(fetch_response)
        user.login.should == "wilma"
        user.name.should == ""
        user.email.should == "wilma@example.com"
        user.should be_valid
      }.should change(User, :count).by(1)
    end

    it "should retrieve a user if they already exist" do
      User.create!(:login => "wilma", :email => "wilma@example.com", :name => "Wilma Flintstone", :password => "password", :password_confirmation => "password")
      fetch_response = mock()
      fetch_response.should_receive(:get_single).with('http://axschema.org/contact/email').and_return("wilma@example.com")
      fetch_response.should_receive(:get_single).with('http://axschema.org/namePerson/first').and_return("Wilma")
      fetch_response.should_receive(:get_single).with('http://axschema.org/namePerson/last').and_return("Flintstone")

      lambda {
        User.find_or_create_from_google_openid(fetch_response)
      }.should_not change(User, :count)
    end

  end

  protected

  def create_user(options = {})
    record = User.new({:login => 'quire', :email => 'quire@example.com', :password => 'quire69', :password_confirmation => 'quire69'}.merge(options))
    record.save
    record
  end
end
