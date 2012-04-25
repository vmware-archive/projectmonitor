FactoryGirl.define do
  factory :user do
    login { Faker::Name.first_name.downcase.gsub(/[^a-z0-9\.-_@]/, '') }
    email { Faker::Internet.email }
    password { "monkey" }
    password_confirmation { password }
  end
end
