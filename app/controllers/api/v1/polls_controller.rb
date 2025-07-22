class Api::V1::PollsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!

  def show
    user = User.find(params[:user_id])
    poll = Poll.find(params[:id])

    if user.book_clubs.include?(poll.book_club)
      render json: PollSerializer.new(poll, params: { current_user: current_user }), status: :ok
    else
      render json: ErrorSerializer.format_errors(["You are not authorized to view this poll"]), status: :forbidden
    end
  end

  def create
    book_club = BookClub.find(params[:book_club_id])
    poll = book_club.polls.new(poll_params)
    if poll.save
      render json: PollSerializer.new(poll, params: { current_user: current_user }), status: :created
    else
      render json: { errors: poll.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def poll_params
    params.require(:poll).permit(
      :poll_question,
      :expiration_date,
      :multiple_votes,
      options_attributes: [:option_text]
    )
  end

end