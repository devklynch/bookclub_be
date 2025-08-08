FactoryBot.define do
  factory :poll do
    poll_question { "MyString" }
    expiration_date { "2025-03-09 11:33:10" }
    multiple_votes { false }
  end
end
