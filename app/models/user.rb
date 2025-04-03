class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
    has_many :members
    has_many :book_clubs, through: :members

    has_many :attendees
    has_many :events, through: :attendees
    
    has_many :votes
    has_many :options, through: :votes

    validates :email, presence: true, uniqueness: true
    validates :display_name, presence: true, allow_blank: false
    validates :password, presence: { require: true }
end
