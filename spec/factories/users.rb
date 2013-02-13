FactoryGirl.define do
    sequence(:login) {|n| "#{Faker::Name.name.downcase.gsub(/[^a-z0-9\.-_@]/, '')}_#{n}" }
    sequence(:email) {|n| "#{n}#{Faker::Internet.email}" }

  factory :user do
    login
    email
    password "monkey"
    password_confirmation { password }
  end
end
