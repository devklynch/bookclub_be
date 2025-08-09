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
    
    render json: BookClubSerializer.new(user.book_clubs, params: { current_user: current_user }), status: :ok
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

  def polls
    user = User.find(params[:id])
    
    authorize user, :polls?
    
    active_polls = Poll.joins(:book_club)
                       .where('polls.expiration_date >= ?', Date.current)
                       .where(book_clubs: { id: user.book_club_ids })
                       .distinct
                       .order(:expiration_date)
    
    expired_polls = Poll.joins(:book_club)
                        .where('polls.expiration_date < ?', Date.current)
                        .where(book_clubs: { id: user.book_club_ids })
                        .distinct
                        .order(expiration_date: :desc)
    
    render json: {
      data: {
        active_polls: PollSerializer.new(active_polls, params: { current_user: current_user }).serializable_hash[:data],
        expired_polls: PollSerializer.new(expired_polls, params: { current_user: current_user }).serializable_hash[:data]
      }
    }, status: :ok
  end
end