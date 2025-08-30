class Api::V1::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:update]

  def update
    authorize @user, :update?

    # Handle password change separately
    if user_params[:password].present?
      unless @user.valid_password?(user_params[:current_password])
        render json: {
          error: "Current password is incorrect",
          errors: { current_password: ["is incorrect"] }
        }, status: :unprocessable_entity
        return
      end
      
      # Use regular update when changing password
      update_params = user_params.except(:current_password)
      success = @user.update(update_params)
    else
      # Use update_without_password when not changing password
      update_params = user_params.except(:current_password, :password, :password_confirmation)
      success = @user.update_without_password(update_params)
    end
    
    if success
      render json: {
        message: "Profile updated successfully",
        data: UserSerializer.new(@user).serializable_hash[:data]
      }, status: :ok
    else
      render json: {
        error: "Failed to update profile",
        errors: @user.errors.as_json
      }, status: :unprocessable_entity
    end
  end

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

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :display_name, :password, :password_confirmation, :current_password)
  end
end