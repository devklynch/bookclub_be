class Invitation < ApplicationRecord
  belongs_to :book_club
  belongs_to :invited_by, class_name: 'User'
  
  before_validation :normalize_email
  
  validates :email, presence: true, 
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" },
            length: { maximum: 254, message: "is too long (maximum is 254 characters)" },
            format: { without: /\s/, message: "cannot contain spaces" }
  validates :status, inclusion: { in: %w[pending accepted declined expired] }
  validates :email, uniqueness: { scope: :book_club_id, message: "has already been invited to this book club" }
  
  before_create :set_defaults
  after_create :send_invitation_email
  
  scope :pending, -> { where(status: 'pending') }
  scope :accepted, -> { where(status: 'accepted') }
  scope :expired, -> { where(status: 'expired') }
  
  def expired?
    created_at < 7.days.ago
  end
  
  def can_be_accepted?
    status == 'pending' && !expired?
  end
  
  def accept!(user)
    return false unless can_be_accepted?
    
    transaction do
      update!(status: 'accepted')
      
      # Check if user is already a member
      unless book_club.users.include?(user)
        book_club.members.create!(user: user)
      end
    end
  rescue => e
    Rails.logger.error "Failed to accept invitation: #{e.message}"
    Rails.logger.error "User: #{user.id}, Book Club: #{book_club.id}"
    false
  end
  
  def decline!
    update!(status: 'declined')
  end
  
  private
  
  def set_defaults
    self.status ||= 'pending'
    self.token ||= SecureRandom.urlsafe_base64(32)
  end

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
  
  def send_invitation_email
    # This will be implemented with ActionMailer
    begin
      InvitationMailer.invite(self).deliver_later
    rescue => e
      Rails.logger.error "Failed to send invitation email: #{e.message}"
      # Don't fail the invitation creation if email fails
    end
  end
end
