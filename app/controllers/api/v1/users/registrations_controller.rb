module Api
  module V1
    module Users
      class RegistrationsController < Devise::RegistrationsController
        protect_from_forgery with: :null_session
        respond_to :json

        def create
          # Validate required parameters first
          if missing_required_params?
            return render json: ErrorSerializer.format_errors(["Email, password, password confirmation, and display name are required"]), status: :bad_request
          end

          @user = User.new(user_params)
          
          if @user.save
            # Process invitation if present
            invitation_token = params[:invitation_token]
            if invitation_token
              process_invitation(invitation_token, @user)
            end
            
            # Generate JWT token for immediate authentication
            token = @user.generate_jwt
            
            render json: {
              user: UserSerializer.new(@user),
              token: token,
              message: invitation_token ? "Account created and invitation accepted!" : "User account created successfully"
            }, status: :created
          else
            render json: ErrorSerializer.format_errors(@user.errors.full_messages), status: :unprocessable_entity
          end
        end

        private

        def user_params
          params.require(:user).permit(:email, :password, :password_confirmation, :display_name)
        end

        def missing_required_params?
          user_params = params[:user] || {}
          user_params[:email].blank? || 
          user_params[:password].blank? || 
          user_params[:password_confirmation].blank? || 
          user_params[:display_name].blank?
        end

        def process_invitation(token, user)
          invitation = Invitation.find_by(token: token, status: 'pending')
          
          if invitation && invitation.can_be_accepted?
            invitation.accept!(user)
          end
        rescue => e
          Rails.logger.error "Failed to process invitation: #{e.message}"
        end
      end
    end
  end
end 