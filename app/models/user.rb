class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :validatable,
  :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::JTIMatcher
  before_validation :set_jti, on: :create
  before_validation :normalize_email

    has_many :members
    has_many :book_clubs, through: :members

    has_many :attendees
    has_many :events, through: :attendees
    
    has_many :votes
    has_many :options, through: :votes

    validates :email, presence: true, uniqueness: true, 
              format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
    validates :display_name, presence: true, allow_blank: false,
              length: { minimum: 2, maximum: 50, message: "must be between 2 and 50 characters" }
    validates :password, presence: { require: true },
              length: { minimum: 6, message: "must be at least 6 characters long" }
    validate :password_complexity

    def set_jti
      self.jti ||= SecureRandom.uuid
    end

    def generate_jwt
      JWT.encode({ user_id: id, exp: 60.days.from_now.to_i }, Rails.application.credentials.secret_key_base)
    end

    private

    def normalize_email
      self.email = email.downcase.strip if email.present?
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
