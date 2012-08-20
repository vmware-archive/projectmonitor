FactoryGirl.define do
  factory :project_status do
    success { [true, false].sample }
    build_id { rand(1000) }
  end
end
