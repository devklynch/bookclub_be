FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { "password123" }
    display_name { Faker::Name.unique.name }
  end
end
