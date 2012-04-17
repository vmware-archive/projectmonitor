FactoryGirl.define do
  factory :user do
    login { Faker::Name.first_name }
    email { Faker::Internet.email }
    password { "monkey" }
    password_confirmation { password }
  end
end
