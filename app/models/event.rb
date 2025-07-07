class Event < ApplicationRecord
    belongs_to :book_club

    has_many :attendees, dependent: :destroy
    has_many :users, through: :attendees

    validates :event_name, presence: true
    validates :event_date, presence: true
    validates :location, presence: true
    validates :book, presence: true, allow_blank: true
    validates :event_notes, presence: true, allow_blank: true

    after_create :add_attendees

    private

    def add_attendees
        book_club.users.find_each do |user|
            attendees.create!(user: user, attending: nil)
        end
    end
end
