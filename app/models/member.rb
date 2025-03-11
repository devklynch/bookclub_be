class Member < ApplicationRecord
    belongs_to :user
    belongs_to :book_club
end
