class Attendee < ApplicationRecord
    belongs_to :user
    belongs_to :event

    validates :attending, inclusion: { in: [true, false], allow_nil: true }
    validates :user_id, uniqueness: { scope: :event_id, message: "is already registered for this event" }
    validate :user_must_be_member_of_book_club
    
    private
    
    def user_must_be_member_of_book_club
      if user && event && !event.book_club.users.include?(user)
        errors.add(:user_id, "must be a member of the book club to attend events")
      end
    end
end
