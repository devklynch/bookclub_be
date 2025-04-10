require 'rails_helper'

RSpec.describe Option, type: :model do
  describe "associations" do
    it { should belong_to(:poll) }
    it { should have_many(:votes).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:option_text) }
    it { should allow_value(nil).for(:additional_info) }
    it { should validate_length_of(:additional_info).is_at_most(500) }
  end
end
