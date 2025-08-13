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
            Rails.logger.info "=== Password Reset Flow Debug ==="
            Rails.logger.info "User ID: #{user.id}"
            Rails.logger.info "User email: #{user.email}"
            Rails.logger.info "Before token generation:"
            Rails.logger.info "  User reset token: #{user.reset_password_token}"
            Rails.logger.info "  User reset password sent at: #{user.reset_password_sent_at}"
            
            # Manually generate the reset token using Devise's token generator
            raw_token, encrypted_token = Devise.token_generator.generate(User, :reset_password_token)
            
            # Store the encrypted token in the database
            user.reset_password_token = encrypted_token
            user.reset_password_sent_at = Time.current
            user.save!
            
            Rails.logger.info "After manual token generation:"
            Rails.logger.info "  Raw token: #{raw_token}"
            Rails.logger.info "  Encrypted token: #{encrypted_token}"
            Rails.logger.info "  User reset token: #{user.reset_password_token}"
            Rails.logger.info "  User reset password sent at: #{user.reset_password_sent_at}"
            
            # Send email using our custom mailer with the raw token
            Rails.logger.info "Sending email with raw token: #{raw_token}"
            CustomDeviseMailer.reset_password_instructions(user, raw_token).deliver_now
            Rails.logger.info "Email sent successfully"
            
            # Reload user to ensure we have the latest data
            user.reload
            
            Rails.logger.info "After email sent and reload:"
            Rails.logger.info "  User reset token: #{user.reset_password_token}"
            Rails.logger.info "  User reset password sent at: #{user.reset_password_sent_at}"
            Rails.logger.info "=== End Password Reset Flow Debug ==="
            
            render json: {
              message: "Password reset instructions sent to your email"
            }, status: :ok
          else
            # Don't reveal if email exists or not for security
            render json: {
              message: "If an account with that email exists, password reset instructions have been sent"
            }, status: :ok
          end
        rescue => e
          Rails.logger.error "Password reset error: #{e.message}"
          render json: { error: "Failed to send password reset email. Please try again." }, status: :internal_server_error
        end

        # PUT /api/v1/users/password
        def update
          Rails.logger.info "Reset password params: #{params.inspect}"
          Rails.logger.info "Permitted params: #{reset_password_params.inspect}"
          Rails.logger.info "Reset token from params: #{params[:reset_password_token]}"
          
          # Use Devise's built-in method to find and verify the user
          user = User.reset_password_by_token(reset_password_params)
          
          Rails.logger.info "User found: #{user&.email}"
          Rails.logger.info "User reset token: #{user&.reset_password_token}"
          Rails.logger.info "User reset password sent at: #{user&.reset_password_sent_at}"
          Rails.logger.info "Reset period valid: #{user&.reset_password_period_valid?}"
          
          if user.errors.empty?
            # Password was successfully reset
            render json: { message: "Password reset successfully" }, status: :ok
          else
            # There were validation errors
            render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
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