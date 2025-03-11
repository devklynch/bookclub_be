require 'rails_helper'

RSpec.describe Member, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:book_club) }
  end
end
