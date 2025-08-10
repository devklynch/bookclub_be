class InvitationMailer < ApplicationMailer
  def invite(invitation)
    @invitation = invitation
    @book_club = invitation.book_club
    @invited_by = invitation.invited_by
    @existing_user = User.find_by(email: invitation.email)
    
    if @existing_user
      # User already exists - send join invitation
      mail(
        to: invitation.email,
        subject: "You're invited to join #{@book_club.name}!"
      )
    else
      # New user - send signup + join invitation
      mail(
        to: invitation.email,
        subject: "Join #{@book_club.name} - New Book Club Invitation"
      )
    end
  end
  
  def invitation_accepted(invitation)
    @invitation = invitation
    @book_club = invitation.book_club
    @user = User.find_by(email: invitation.email)
    
    mail(
      to: invitation.email,
      subject: "Welcome to #{@book_club.name}!"
    )
  end
end
