module Api
  module V1
    module Users
      class SessionsController < Devise::SessionsController
        skip_before_action :verify_authenticity_token
        respond_to :json
        
        def create
          # Use strong parameters
          email = sign_in_params[:email]
          password = sign_in_params[:password]

          # Validate presence of email and password
          if email.blank? || password.blank?
            return render json: { error: 'Email and password are required' }, status: :bad_request
          end

          user = User.find_for_database_authentication(email: email)

          if user&.valid_password?(password)
            token = user.generate_jwt # Ensure this method exists in the User model
            render json: { token: token, user: UserSerializer.new(user)}, status: :ok
          else
            render json: { error: 'Invalid credentials' }, status: :unauthorized
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