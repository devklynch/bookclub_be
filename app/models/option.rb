class Option < ApplicationRecord
    belongs_to :poll
    has_many :votes, dependent: :destroy
    
    validates :option_text, presence: true
    validates :additional_info, length: { maximum: 500 }, allow_nil: true
end
