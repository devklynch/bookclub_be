class BookClub < ApplicationRecord
    has_many :members, dependent: :destroy
    has_many :users, through: :members

    has_many :events, dependent: :destroy
    has_many :polls, dependent: :destroy

    validates :name, presence: true, allow_blank: false
    validates :description, presence: true, allow_blank: true
end
