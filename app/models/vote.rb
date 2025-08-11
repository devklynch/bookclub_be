class Vote < ApplicationRecord
    belongs_to :user
    belongs_to :option

    validates :user_id, uniqueness: { scope: :option_id, message: "has already voted for this option" }
    validate :poll_not_expired
    
    private
    
    def poll_not_expired
      if option.poll.expired?
        errors.add(:base, "Cannot vote on an expired poll")
      end
    end
end
