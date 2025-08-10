class BookClub < ApplicationRecord
    has_many :members, dependent: :destroy
    has_many :users, through: :members
    
    has_many :book_club_admins
    has_many :admins, through: :book_club_admins, source: :user

    has_many :events, dependent: :destroy
    has_many :polls, dependent: :destroy
    has_many :invitations, dependent: :destroy

    validates :name, presence: true, allow_blank: false
    validates :description, presence: true, allow_blank: true
    
    def admin?(user)
      admins.include?(user)
    end
end
