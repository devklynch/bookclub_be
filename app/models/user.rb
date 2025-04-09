class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :validatable,
  :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::JTIMatcher
  before_validation :set_jti, on: :create

    has_many :members
    has_many :book_clubs, through: :members

    has_many :attendees
    has_many :events, through: :attendees
    
    has_many :votes
    has_many :options, through: :votes

    validates :email, presence: true, uniqueness: true
    validates :display_name, presence: true, allow_blank: false
    validates :password, presence: { require: true }

    def set_jti
      self.jti ||= SecureRandom.uuid
    end

    def generate_jwt
      JWT.encode({ user_id: id, exp: 60.days.from_now.to_i }, Rails.application.credentials.secret_key_base)
    end
end
