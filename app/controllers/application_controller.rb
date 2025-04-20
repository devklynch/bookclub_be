class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  include Pundit::Authorization

  rescue_from ActiveRecord::RecordInvalid do |e|
    render json: ErrorSerializer.format_errors(e.record.errors.full_messages), status: :unprocessable_entity
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: ErrorSerializer.format_errors([e.message]), status: :not_found
  end

  rescue_from Pundit::NotAuthorizedError do |_exception|
    render json: { error: 'You are not authorized to perform this action' }, status: :forbidden
  end

  def render_error
    render json: ErrorSerializer.format_errors(["Invalid search request"]), status: :bad_request
  end
  
  def current_user
    @current_user
  end

  private

  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last

    if token.present?
      begin
        payload = JWT.decode(token, Rails.application.credentials.secret_key_base, true, algorithm: 'HS256').first
        @current_user = User.find(payload['user_id'])
   
      rescue JWT::DecodeError, ActiveRecord::RecordNotFound
        render json: { error: 'Invalid or expired token' }, status: :unauthorized
      end
    else
      render json: { error: 'Token is missing' }, status: :unauthorized
    end
  end

end
