FactoryGirl.define do
  factory :project do |f|
    name { Faker::Name.name }
    feed_url { Faker::Internet.domain_name }
  end
end
