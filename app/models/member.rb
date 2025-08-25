class Member < ApplicationRecord
    belongs_to :user
    belongs_to :book_club
    
    validates :user_id, uniqueness: { scope: :book_club_id, message: "is already a member of this book club" }
    validate :user_cannot_be_admin_and_member
    
    private
    
    def user_cannot_be_admin_and_member
      if user && book_club && book_club.admin?(user)
        errors.add(:user_id, "cannot be both an admin and a regular member")
      end
    end
end
