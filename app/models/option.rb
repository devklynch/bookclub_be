class Option < ApplicationRecord
    belongs_to :poll
    has_many :votes, dependent: :destroy
    
    before_validation :sanitize_option_text
    before_validation :sanitize_additional_info

    validates :option_text, presence: true,
              length: { minimum: 1, maximum: 200, message: "must be between 1 and 200 characters" },
              format: { without: /[<>]/, message: "cannot contain HTML tags" }
    validates :additional_info, length: { maximum: 500, message: "is too long (maximum is 500 characters)" }, 
              allow_nil: true,
              format: { without: /[<>]/, message: "cannot contain HTML tags" }

    private

    def sanitize_option_text
      self.option_text = option_text&.strip&.gsub(/\s+/, ' ') if option_text.present?
    end

    def sanitize_additional_info
      self.additional_info = additional_info&.strip if additional_info.present?
    end
end
