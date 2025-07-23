class Poll < ApplicationRecord
    belongs_to :book_club
    has_many :options, dependent: :destroy

    accepts_nested_attributes_for :options, allow_destroy: true
    
    validates :poll_question, presence: true
    validates :expiration_date, presence: true
    validates :multiple_votes, inclusion: {in:[true,false]}
end
