module Api
  module V1
    module Users
      class RegistrationsController < Devise::RegistrationsController
        skip_before_action :verify_authenticity_token
        respond_to :json

        def create
          @user = User.new(user_params)
          if @user.save
            render json: UserSerializer.new(@user), status: :created
          else
            render json: ErrorSerializer.format_errors((@user.errors.full_messages)), status: :unprocessable_entity
          end
        end

        private

        def user_params
          params.require(:user).permit(:email, :password, :password_confirmation, :display_name)
        end
      end
    end
  end
end