require 'xmlsimple'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message

  attr_accessible :login, :email, :name, :password, :password_confirmation

  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_by_login(login.downcase) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def self.find_or_create_from_google_access_token(access_token)
    oauth_secret = access_token.secret
    xml_string = access_token.get("https://www.google.com/m8/feeds/contacts/default/full/").body
    xml = XmlSimple.xml_in(xml_string)
    email = xml["author"].first["email"].first
    user = User.find_by_email(email) || User.new(:email => email)
    user.name = xml["author"].first["name"].first
    user.login = email.split('@').first
    user.password = oauth_secret
    user.password_confirmation = oauth_secret
    user.save!
    user
  end
end
