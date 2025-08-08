class Api::V1::UsersController < ApplicationController
  before_action :authenticate_user!

  def all_club_data
    user = User.find(params[:id])
 
    authorize user, :all_club_data?

    render json: AllClubDataSerializer.new(user), status: :ok
  end

  def book_clubs
    user = User.find(params[:id])
    
    authorize user, :book_clubs?
    
    render json: BookClubSerializer.new(user.book_clubs), status: :ok
  end

  def events
    user = User.find(params[:id])
    
    authorize user, :events?
    
    upcoming_events = user.events.where('event_date >= ?', Date.current).order(:event_date)
    past_events = user.events.where('event_date < ?', Date.current).order(event_date: :desc)
    
    render json: {
      data: {
        upcoming_events: EventSerializer.new(upcoming_events, params: { current_user: current_user }).serializable_hash[:data],
        past_events: EventSerializer.new(past_events, params: { current_user: current_user }).serializable_hash[:data]
      }
    }, status: :ok
  end
end