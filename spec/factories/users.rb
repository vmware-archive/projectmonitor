FactoryGirl.define do
  sequence :login do |n|
    "#{Faker::Name.name.downcase.gsub(/[^a-z0-9\.-_@]/, '')}_#{n}"
  end

  factory :user do
    login
    email { Faker::Internet.email }
    password "monkey"
    password_confirmation { password }
  end
end
