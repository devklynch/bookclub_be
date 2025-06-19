class Vote < ApplicationRecord
    belongs_to :user
    belongs_to :option

    validates :user_id, uniqueness: { scope: :option_id, message: "has already voted for this option" }
end
