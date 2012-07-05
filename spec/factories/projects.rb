FactoryGirl.define do
  factory :project do |f|
    name { Faker::Name.name }
    feed_url { Faker::Internet.domain_name }

    factory :project_with_tracker_integration do |f|
      tracker_project_id { "123" }
      tracker_auth_token { "foo" }
    end
  end
end
