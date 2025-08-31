class Api::V1::VotesController < ApplicationController

  before_action :authenticate_user!

  def create
    option = Option.find(params[:option_id])
    poll = option.poll

    # Check if poll is expired before allowing any votes
    if poll.expired?
      render json: { error: "This poll has expired and is no longer accepting votes." }, status: :unprocessable_entity
      return
    end

    if !poll.multiple_votes
      # For single-vote polls: block if user has any vote in this poll
      already_voted = Vote.joins(:option)
                          .where(user_id: current_user.id, options: { poll_id: poll.id })
                          .exists?

      if already_voted
        render json: { error: "You can only vote once in this poll." }, status: :unprocessable_entity
        return
      end
    end

    vote = option.votes.build(user: current_user)

    if vote.save
      render json: vote, status: :created
    else
      render json: { errors: vote.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    vote = Vote.find_by(id: params[:id], user: current_user)

    if vote
      # Check if poll is expired before allowing vote removal
      if vote.option.poll.expired?
        render json: { error: "Cannot remove votes from an expired poll." }, status: :unprocessable_entity
        return
      end
      
      vote.destroy
      render json: { message: "Vote removed" }, status: :ok
    else
      render json: { error: "Vote not found or not authorized" }, status: :not_found
    end
  end
end