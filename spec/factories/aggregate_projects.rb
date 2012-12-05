FactoryGirl.define do
  factory :aggregate_project do
    name { Faker::Name.name }

    factory :aggregate_project_with_project do
      after(:create) do |aggregate, evaluator|
        FactoryGirl.create(:project, aggregate_project: aggregate)
      end
    end
  end
end
