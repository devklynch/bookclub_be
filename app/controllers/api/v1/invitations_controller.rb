module Api
  module V1
    class InvitationsController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :authenticate_user!
      before_action :set_book_club, only: [:create, :index]
      before_action :ensure_admin, only: [:create, :index]
      before_action :set_invitation, only: [:accept, :decline]

      def create
        @invitation = @book_club.invitations.build(invitation_params)
        @invitation.invited_by = current_user

        Rails.logger.info "Creating invitation: #{@invitation.attributes}"
        Rails.logger.info "Current user: #{current_user.id}"
        Rails.logger.info "Book club: #{@book_club.id}"
        Rails.logger.info "Is admin? #{@book_club.admin?(current_user)}"

        if @invitation.save
          render json: {
            message: "Invitation sent to #{@invitation.email}",
            invitation: InvitationSerializer.new(@invitation)
          }, status: :created
        else
          Rails.logger.error "Invitation validation errors: #{@invitation.errors.full_messages}"
          Rails.logger.error "Invitation errors details: #{@invitation.errors.details}"
          render json: { errors: @invitation.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def index
        @invitations = @book_club.invitations.includes(:invited_by).order(created_at: :desc)
        render json: InvitationSerializer.new(@invitations)
      end

      def accept
        if @invitation.accept!(current_user)
          # Send welcome email
          InvitationMailer.invitation_accepted(@invitation).deliver_later
          
          render json: {
            message: "Successfully joined #{@invitation.book_club.name}!",
            book_club: BookClubSerializer.new(@invitation.book_club, params: { current_user: current_user })
          }
        else
          render json: { errors: ["Unable to accept invitation"] }, status: :unprocessable_entity
        end
      end

      def decline
        if @invitation.decline!
          render json: { message: "Invitation declined" }
        else
          render json: { errors: ["Unable to decline invitation"] }, status: :unprocessable_entity
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
        Rails.logger.info "Checking admin status for user #{current_user.id} in book club #{@book_club.id}"
        Rails.logger.info "Book club admins: #{@book_club.admins.pluck(:id)}"
        Rails.logger.info "Is admin? #{@book_club.admin?(current_user)}"
        
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
