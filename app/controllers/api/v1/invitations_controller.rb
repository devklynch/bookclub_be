module Api
  module V1
    class InvitationsController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :authenticate_user!, only: [:create, :index]
      before_action :set_book_club, only: [:create, :index]
      before_action :ensure_admin, only: [:create, :index]
      before_action :set_invitation, only: [:accept, :decline]

      def create
        @invitation = @book_club.invitations.build(invitation_params)
        @invitation.invited_by = current_user

        Rails.logger.info "Creating invitation for email: #{@invitation.email}"
        Rails.logger.info "Invitation created by authenticated user"
        Rails.logger.info "Book club invitation created successfully"

        if @invitation.save
          render json: {
            message: "Invitation sent to #{@invitation.email}",
            invitation: InvitationSerializer.new(@invitation)
          }, status: :created
        else
          Rails.logger.error "Invitation validation errors: #{@invitation.errors.full_messages}"
          Rails.logger.error "Invitation creation failed"
          render json: { errors: @invitation.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def index
        @invitations = @book_club.invitations.includes(:invited_by).order(created_at: :desc)
        render json: InvitationSerializer.new(@invitations)
      end

      def accept
        # For unauthenticated users, we'll redirect to frontend
        unless current_user
          redirect_to "#{Rails.application.config.x.frontend_url}/invitation-accepted?token=#{@invitation.token}&book_club=#{@invitation.book_club.name}"
          return
        end
        
        Rails.logger.info "Processing invitation acceptance for authenticated user"
        
        if @invitation.accept!(current_user)
          # Send welcome email
          InvitationMailer.invitation_accepted(@invitation).deliver_later
          
          Rails.logger.info "Invitation accepted successfully"
          redirect_to "#{Rails.application.config.x.frontend_url}/invitation-accepted?token=#{@invitation.token}&book_club=#{@invitation.book_club.name}"
        else
          Rails.logger.error "Failed to accept invitation"
          redirect_to "#{Rails.application.config.x.frontend_url}/invitation-error?error=Unable to accept invitation"
        end
      end

      def decline
        if @invitation.decline!
          redirect_to "#{Rails.application.config.x.frontend_url}/invitation-declined?book_club=#{@invitation.book_club.name}"
        else
          redirect_to "#{Rails.application.config.x.frontend_url}/invitation-error?error=Unable to decline invitation"
        end
      end

      private

      def set_book_club
        @book_club = BookClub.find(params[:book_club_id])
      end

      def set_invitation
        @invitation = Invitation.find_by!(token: params[:token])
      end

      def ensure_admin
        Rails.logger.info "Checking admin status for user in book club"
        Rails.logger.info "Admin verification completed"
        
        unless @book_club.admin?(current_user)
          render json: { errors: ["Only book club admins can manage invitations"] }, status: :forbidden
        end
      end

      def invitation_params
        params.require(:invitation).permit(:email)
      end
    end
  end
end
