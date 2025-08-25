class Poll < ApplicationRecord
    belongs_to :book_club
    has_many :options, dependent: :destroy

    accepts_nested_attributes_for :options, allow_destroy: true
    
    before_validation :sanitize_poll_question

    validates :poll_question, presence: true,
              length: { minimum: 1, maximum: 500, message: "must be between 1 and 500 characters" },
              format: { without: /[<>]/, message: "cannot contain HTML tags" }
    validates :expiration_date, presence: true,
              comparison: { greater_than: Time.current, message: "must be in the future" }
    validates :multiple_votes, inclusion: {in:[true,false]}
    
    validate :expiration_date_not_too_far_in_future
    validate :has_at_least_two_options
    
    def expired?
      expiration_date < Time.current
    end
    
    def accepting_votes?
      !expired?
    end
    
    # Serializer methods
    def expired
      expired?
    end
    
    def accepting_votes
      accepting_votes?
    end

    private

    def sanitize_poll_question
      self.poll_question = poll_question&.strip&.gsub(/\s+/, ' ') if poll_question.present?
    end

    def expiration_date_not_too_far_in_future
      if expiration_date && expiration_date > 1.year.from_now
        errors.add(:expiration_date, "cannot be more than 1 year in the future")
      end
    end

    def has_at_least_two_options
      if options.size < 2
        errors.add(:options, "must have at least 2 options")
      end
    end
end
