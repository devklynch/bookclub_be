class Api::V1::EventsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!

  def show
    event = Event.find(params[:id])
    
    if event.book_club_id != params[:book_club_id].to_i
      return render json: { errors: ["Event does not belong to the specified book club"] }, status: :not_found
    end

    unless event.book_club.users.include?(current_user)
      return render json: ErrorSerializer.format_errors(["You are not authorized to view this event"]), status: :forbidden
    end

    render json: EventSerializer.new(event, params: { current_user: current_user }), status: :ok
  end


  def create
    club = BookClub.find(params[:book_club_id])

    unless club.users.include?(current_user)
      return render json: { errors: ["You are not authorized to create events for this book club"] }, status: :forbidden
    end
    event = club.events.create!(event_params)


      render json: EventSerializer.new(event, params: { current_user: current_user }), status: :ok
  end

  private

  def event_params
    params.require(:event).permit(:event_name, :event_date, :location, :book, :event_notes)
  end


end