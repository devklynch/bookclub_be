class Attendee < ApplicationRecord
    belongs_to :user
    belongs_to :event

    validates :attending, inclusion: { in: [true, false] }
end
