require Rails.root.join('lib', 'devise', 'encryptors', 'legacy')

class User < ActiveRecord::Base
  devise_options = [:database_authenticatable,
    :recoverable, :rememberable, :trackable, :omniauthable]
  devise_options << :encryptable if ConfigHelper.get(:devise_encryptor)
  devise *devise_options

  validates :password, confirmation: true
  validates :login, presence: true, length: 2..40, uniqueness: true
  validates_length_of :name, maximum: 100
  validates :email, presence: true, length: 6..100, uniqueness: true

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(login) = :value OR lower(email) = :value", { value: login.downcase }]).first
    else
      where(conditions).first
    end
  end

  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    data = access_token.info
    user = User.where(email: data["email"]).first
    user || User.create!(name: data["name"],
                        email: data["email"],
                        login: data["email"].split('@').first,
                        password: Devise.friendly_token[0,20])
  end

end
