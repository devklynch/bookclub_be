class Vote < ApplicationRecord
    belongs_to :user
    belongs_to :option

    validates :user_id, uniqueness: { scope: :option_id, message: "has already voted for this option" }
    validate :poll_not_expired
    validate :user_must_be_member_of_book_club
    
    private
    
    def poll_not_expired
      if option.poll.expired?
        errors.add(:base, "Cannot vote on an expired poll")
      end
    end
    
    def user_must_be_member_of_book_club
      if user && option && !option.poll.book_club.users.include?(user)
        errors.add(:user_id, "must be a member of the book club to vote on polls")
      end
    end
end
