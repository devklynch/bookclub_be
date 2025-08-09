class BookClubAdmin < ApplicationRecord
  belongs_to :user
  belongs_to :book_club
  
  validates :user_id, uniqueness: { scope: :book_club_id }
end
