class BookClub < ApplicationRecord
    has_many :members, dependent: :destroy
    has_many :users, through: :members
end
