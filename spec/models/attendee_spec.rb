require 'rails_helper'

RSpec.describe Attendee, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:event) }
  end

  describe "validations" do
    it { should validate_inclusion_of(:attending).in_array([true, false]) }
  end
end
