require 'rails_helper'

RSpec.describe Poll, type: :model do
  describe "associations" do
    it { should belong_to(:book_club) }
    it { should have_many(:options).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:poll_question) }
    it { should validate_presence_of(:expiration_date) }
  end
end
