require 'rails_helper'

RSpec.describe BookClub, type: :model do
  describe "associations" do
    it { should have_many(:members) }
    it { should have_many(:users).through(:members) }
    it { should have_many(:polls) }
    it { should have_many(:events) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should_not validate_presence_of(:description) }
  end
end
