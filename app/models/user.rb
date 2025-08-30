class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :validatable
  before_validation :set_jti, on: :create
  before_validation :normalize_email
  before_validation :sanitize_display_name

    has_many :members
    has_many :book_clubs, through: :members
    
    has_many :book_club_admins
    has_many :administered_book_clubs, through: :book_club_admins, source: :book_club

    has_many :attendees
    has_many :events, through: :attendees
    
    has_many :votes
    has_many :options, through: :votes

    validates :email, presence: true, uniqueness: true, 
              format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" },
              length: { maximum: 254, message: "is too long (maximum is 254 characters)" }
    validates :display_name, presence: true, allow_blank: false,
              length: { minimum: 2, maximum: 50, message: "must be between 2 and 50 characters" },
              format: { without: /[<>]/, message: "cannot contain HTML tags" }
    validates :password, presence: { require: true },
              length: { minimum: 6, message: "must be at least 6 characters long" },
              unless: :skip_password_validation?
    validate :password_complexity, unless: :skip_password_validation?

    def set_jti
      self.jti ||= SecureRandom.uuid
    end

    def generate_jwt
      JWT.encode({ 
        sub: id.to_s,
        jti: jti, 
        exp: 24.hours.from_now.to_i,
        aud: 'user'
      }, Rails.application.credentials.secret_key_base)
    end

    def reset_password_token_present?
      reset_password_token.present?
    end

    def skip_password_validation?
      # Skip validation during password reset
      return true if reset_password_token_present?
      
      # Skip validation when not changing password (password is blank during update)
      return true if persisted? && password.blank?
      
      false
    end

    private

    def normalize_email
      self.email = email.downcase.strip if email.present?
    end

    def sanitize_display_name
      self.display_name = display_name&.strip&.gsub(/\s+/, ' ') if display_name.present?
    end

    def password_complexity
      return if password.blank?
      
      unless password.match?(/\d/)
        errors.add(:password, "must contain at least one number")
      end
      
      unless password.match?(/[a-z]/)
        errors.add(:password, "must contain at least one lowercase letter")
      end
      
      unless password.match?(/[A-Z]/)
        errors.add(:password, "must contain at least one uppercase letter")
      end
    end
end
