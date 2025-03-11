require 'rails_helper'

RSpec.describe User, type: :model do
  describe "associations" do
    it { should have_many(:members) }
    it { should have_many(:book_clubs).through(:members) }

    # it { should have_many(:attendees) }
    # it { should have_many(:events).through(:attendees) }

    # it { should have_many(:votes) }
    # it { should have_many(:options).through(:votes) }
  end

  describe "validations" do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }

    it { should validate_presence_of(:display_name) }
    
    it { should validate_presence_of(:password) }
  end
end
