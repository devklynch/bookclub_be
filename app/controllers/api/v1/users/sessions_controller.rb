module Api
  module V1
    module Users
      class SessionsController < Devise::SessionsController
        skip_before_action :verify_signed_out_user, only: [:destroy]
        
        def create
        
          email = sign_in_params[:email]
          password = sign_in_params[:password]

          if email.blank? || password.blank?
            return render json: ErrorSerializer.format_errors(['Email and password are required']), status: :bad_request
          end

          user = User.find_for_database_authentication(email: email)

          if user&.valid_password?(password)
            token = user.generate_jwt
            render json: { token: token, user: UserSerializer.new(user)}, status: :ok
          else
            render json: ErrorSerializer.format_errors(['Invalid credentials']), status: :unauthorized
          end
        end

        def destroy
          # Extract and validate the JWT token
          token = request.headers['Authorization']&.split(' ')&.last
          
          if token.blank?
            return render json: ErrorSerializer.format_errors(['Token is missing']), status: :unauthorized
          end
          
          begin
            # Decode the JWT token using your custom method
            payload = JWT.decode(token, Rails.application.credentials.secret_key_base, true, algorithm: 'HS256').first
            # Support both old 'user_id' and new 'sub' formats for backward compatibility
            user_id = payload['sub'] || payload['user_id']
            user = User.find(user_id)
            
            # Invalidate the user's JTI to revoke all their tokens
            user.update!(jti: SecureRandom.uuid)
            
            render json: { message: 'Logged out successfully' }, status: :ok
          rescue JWT::DecodeError, ActiveRecord::RecordNotFound
            render json: ErrorSerializer.format_errors(['Invalid or expired token']), status: :unauthorized
          rescue => e
            render json: ErrorSerializer.format_errors(['Logout failed']), status: :unprocessable_entity
          end
        end

        private

        # Strong parameters for sign-in
        def sign_in_params
          params.permit(:email, :password,session: [:email, :password])
        end
      end
    end
  end
end