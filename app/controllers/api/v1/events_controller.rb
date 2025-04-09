class Api::V1::EventsController < ApplicationController
  before_action :authenticate_user!

  def show
    user = User.find(params[:user_id])
    event = Event.find(params[:id])
    
    if user.book_clubs.include?(event.book_club)
      render json: EventSerializer.new(event), status: :ok
    else
      render json: ErrorSerializer.format_errors(["You are not authorized to view this event"]), status: :forbidden
    end
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

  def current_user
    @current_user
  end
end