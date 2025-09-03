FactoryBot.define do
  factory :poll do
    poll_question { "MyString" }
    expiration_date { "2026-03-09 11:33:10" }
    multiple_votes { false }
    
    # Create 2 default options to satisfy validation
    after(:build) do |poll|
      poll.options.build(option_text: "Option 1")
      poll.options.build(option_text: "Option 2")
    end
  end
end
