FactoryBot.define do
  factory :event do
    event_name { "MyString" }
    event_date { Date.current + 1.week }
    location { "MyString" }
    book { "MyString" }
    event_notes { "MyString" }
  end
end
