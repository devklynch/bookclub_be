class Api::V1::EventsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!

  def show
    user = User.find(params[:user_id])
    event = Event.find(params[:id])
    
    if user.book_clubs.include?(event.book_club)
      render json: EventSerializer.new(event, params: { current_user: current_user }), status: :ok
    else
      render json: ErrorSerializer.format_errors(["You are not authorized to view this event"]), status: :forbidden
    end
  end


  def create
    event = Event.create!(event_params)
      render json: {message: "Hooray"}, status: :created
  end

  private

  def event_params
    params.require(:event).permit(:event_name, :event_date, :location, :book, :event_notes, :book_club_id)
  end


end