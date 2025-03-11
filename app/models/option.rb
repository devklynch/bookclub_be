class Option < ApplicationRecord
    belongs_to :poll
    has_many :votes, dependent: :destroy
    
    validates :option_text, presence: true
end
