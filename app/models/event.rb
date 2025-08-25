class Event < ApplicationRecord
    belongs_to :book_club

    has_many :attendees, dependent: :destroy
    has_many :users, through: :attendees

    before_validation :sanitize_event_name
    before_validation :sanitize_location
    before_validation :sanitize_book
    before_validation :sanitize_event_notes

    validates :event_name, presence: true,
              length: { minimum: 1, maximum: 200, message: "must be between 1 and 200 characters" },
              format: { without: /[<>]/, message: "cannot contain HTML tags" }
    validates :event_date, presence: true,
              comparison: { greater_than: Date.current, message: "must be in the future" }
    validates :location, presence: true,
              length: { minimum: 1, maximum: 200, message: "must be between 1 and 200 characters" },
              format: { without: /[<>]/, message: "cannot contain HTML tags" }
    validates :book, presence: true, allow_blank: true,
              length: { maximum: 200, message: "is too long (maximum is 200 characters)" },
              format: { without: /[<>]/, message: "cannot contain HTML tags" }
    validates :event_notes, presence: true, allow_blank: true,
              length: { maximum: 1000, message: "is too long (maximum is 1000 characters)" },
              format: { without: /[<>]/, message: "cannot contain HTML tags" }

    validate :event_date_not_too_far_in_future

    after_create :add_attendees

    private

    def add_attendees
        book_club.users.find_each do |user|
            attendees.create!(user: user, attending: nil)
        end
    end

    def sanitize_event_name
      self.event_name = event_name&.strip&.gsub(/\s+/, ' ') if event_name.present?
    end

    def sanitize_location
      self.location = location&.strip&.gsub(/\s+/, ' ') if location.present?
    end

    def sanitize_book
      self.book = book&.strip if book.present?
    end

    def sanitize_event_notes
      self.event_notes = event_notes&.strip if event_notes.present?
    end

    def event_date_not_too_far_in_future
      if event_date && event_date > 2.years.from_now
        errors.add(:event_date, "cannot be more than 2 years in the future")
      end
    end
end
