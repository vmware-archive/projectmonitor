require 'openid'
require 'openid/extensions/ax'

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
    self[:login] = value && value.downcase
  end

  def email=(value)
    self[:email] = value && value.downcase
  end

  def self.find_or_create_from_google_openid(fetch_response)
    email = fetch_response.get_single('http://axschema.org/contact/email')
    first_name = fetch_response.get_single('http://axschema.org/namePerson/first')
    last_name = fetch_response.get_single('http://axschema.org/namePerson/last')

    email_parts = email.split('@')
    login = email_parts.first

    user = User.find_by_login(login) || User.new(:login => login)
    full_name = "#{first_name} #{last_name}"
    user.name = full_name.blank? ? "" : full_name
    user.email = email

    # todo - this is a bit of a hack for now...
    user.password = user.password_confirmation = ActiveSupport::SecureRandom.hex(16)
    user.save!
    user
  end

end
