class Poll < ApplicationRecord
    belongs_to :book_club
    has_many :options, dependent: :destroy
    
    validates :poll_question, presence: true
    validates :expiration_date, presence: true
end
