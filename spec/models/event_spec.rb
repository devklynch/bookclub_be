require 'rails_helper'

RSpec.describe Event, type: :model do
  describe "associations" do
    it { should belong_to(:book_club) }
    it { should have_many(:attendees).dependent(:destroy) }
    it { should have_many(:users).through(:attendees) }
  end

  describe "validations" do
    it { should validate_presence_of(:event_name) }
    it { should validate_presence_of(:event_date) }
    it { should validate_presence_of(:location) }
    it { should_not validate_presence_of(:book) }
  end
end
