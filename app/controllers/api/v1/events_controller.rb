class Api::V1::EventsController < ApplicationController
  before_action :authenticate_user!

  def show
    user = User.find(params[:user_id])
    event = Event.find(params[:id])
    
    if user.book_clubs.include?(event.book_club)
      render json: EventSerializer.new(event, eventparams: { current_user: current_user }), status: :ok
    else
      render json: ErrorSerializer.format_errors(["You are not authorized to view this event"]), status: :forbidden
    end
  end

  private


end