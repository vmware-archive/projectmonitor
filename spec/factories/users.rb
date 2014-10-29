FactoryGirl.define do
  factory :user do
    sequence(:login) {|n| "username-#{n}"}
    email {"#{login}@example.com"}
    password "monkey"
    password_confirmation {password}
    sequence(:name) {|n| "Person #{n}"}
  end
end
