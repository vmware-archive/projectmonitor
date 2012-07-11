FactoryGirl.define do
  sequence(:feed_url) { |n| "http://#{n}job/#{n}/rssAll"}

  factory :project, class: JenkinsProject do |f|
    name { Faker::Name.name }
    feed_url { FactoryGirl.generate(:feed_url) }

    factory :project_with_tracker_integration do |f|
      tracker_project_id { "123" }
      tracker_auth_token { "foo" }
    end
  end
end
