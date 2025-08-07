module Api
  module V1
    module Users
      class PasswordsController < Devise::PasswordsController
        skip_before_action :verify_authenticity_token
        respond_to :json

        # POST /api/v1/users/password
        def create
          user = User.find_by(email: params[:email])
          
          if user
            # Generate reset token
            user.send_reset_password_instructions
            
            # Get the reset token that was just generated
            reset_token = user.reset_password_token
            
            # Create the reset URL
            reset_url = "http://localhost:5173/reset_password?reset_password_token=#{reset_token}"
            
            render json: {
              message: "Password reset instructions sent successfully",
              reset_url: reset_url,
              token: reset_token
            }, status: :ok
          else
            render json: { error: "Email not found" }, status: :not_found
          end
        rescue => e
          Rails.logger.error "Password reset error: #{e.message}"
          render json: { error: "Failed to send password reset email. Please try again." }, status: :internal_server_error
        end

        # PUT /api/v1/users/password
        def update
          Rails.logger.info "Reset password params: #{params.inspect}"
          Rails.logger.info "Permitted params: #{reset_password_params.inspect}"
          
          # Find user by reset token
          user = User.find_by(reset_password_token: params[:reset_password_token])
          
          if user && user.reset_password_period_valid?
            # Update password directly
            user.password = params[:password]
            user.password_confirmation = params[:password_confirmation]
            user.reset_password_token = nil
            user.reset_password_sent_at = nil
            
            if user.save
              user.unlock_access! if unlockable?(user)
              render json: { message: "Password reset successfully" }, status: :ok
            else
              render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
            end
          else
            render json: { error: "Invalid or expired reset token" }, status: :unprocessable_entity
          end
        end

        private

        def reset_password_params
          params.permit(:reset_password_token, :password, :password_confirmation)
        end
      end
    end
  end
end 