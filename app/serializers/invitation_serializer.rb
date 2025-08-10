class InvitationSerializer
  include JSONAPI::Serializer
  
  attributes :id, :email, :status, :created_at, :accepted_at, :declined_at
  
  attribute :invited_by do |invitation|
    {
      id: invitation.invited_by.id,
      email: invitation.invited_by.email
    }
  end
  
  attribute :book_club do |invitation|
    {
      id: invitation.book_club.id,
      name: invitation.book_club.name
    }
  end
  
  attribute :expires_at do |invitation|
    invitation.created_at + 7.days
  end
  
  attribute :is_expired do |invitation|
    invitation.expired?
  end
end
