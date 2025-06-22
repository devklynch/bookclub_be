class Api::V1::PollsController < ApplicationController
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
end