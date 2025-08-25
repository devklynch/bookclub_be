class BookClub < ApplicationRecord
    has_many :members, dependent: :destroy
    has_many :users, through: :members
    
    has_many :book_club_admins
    has_many :admins, through: :book_club_admins, source: :user

    has_many :events, dependent: :destroy
    has_many :polls, dependent: :destroy
    has_many :invitations, dependent: :destroy

    before_validation :sanitize_name
    before_validation :sanitize_description

    validates :name, presence: true, allow_blank: false,
              length: { minimum: 1, maximum: 100, message: "must be between 1 and 100 characters" },
              format: { without: /[<>]/, message: "cannot contain HTML tags" }
    validates :description, presence: true, allow_blank: true,
              length: { maximum: 1000, message: "is too long (maximum is 1000 characters)" },
              format: { without: /[<>]/, message: "cannot contain HTML tags" }
    
    def admin?(user)
      admins.include?(user)
    end

    private

    def sanitize_name
      self.name = name&.strip&.gsub(/\s+/, ' ') if name.present?
    end

    def sanitize_description
      self.description = description&.strip if description.present?
    end
end
