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

  def create
    book_club = BookClub.find(params[:book_club_id])
    
    unless book_club.admin?(current_user)
      return render json: ErrorSerializer.format_errors(["Only admins can create polls for this book club"]), status: :forbidden
    end
    
    poll = book_club.polls.new(poll_create_params)
    if poll.save
      render json: PollSerializer.new(poll, params: { current_user: current_user }), status: :created
    else
      render json: ErrorSerializer.format_errors(poll.errors.full_messages), status: :unprocessable_entity
    end
  end

  def update
    book_club = BookClub.find(params[:book_club_id])
    poll = book_club.polls.find(params[:id])

    unless book_club.admin?(current_user)
      return render json: ErrorSerializer.format_errors(["Only admins can update polls for this book club"]), status: :forbidden
    end

    if poll.update(poll_update_params)
      handle_option_updates(poll, params[:poll][:options]) if params[:poll][:options]
      render json: PollSerializer.new(poll, params: { current_user: current_user }), status: :ok
  else
    render json: ErrorSerializer.format_errors(poll.errors.full_messages), status: :unprocessable_entity
    end
  end

  private

  def poll_create_params
    params.require(:poll).permit(
      :poll_question,
      :expiration_date,
      :multiple_votes,
      options_attributes: [
        :id,            
        :option_text,
        :_destroy
      ]
    )
  end

  def poll_update_params
    params.require(:poll).permit(:poll_question, :expiration_date, :multiple_votes)
  end

  def handle_option_updates(poll, options_params)
    # Add new options
    if options_params[:to_add]
      options_params[:to_add].each do |option_attrs|
        poll.options.create(option_attrs.permit(:option_text, :additional_info))
      end
    end
  
    # Update existing options
    if options_params[:to_update]
      options_params[:to_update].each do |option_attrs|
        option = poll.options.find_by(id: option_attrs[:id])
        option.update(option_attrs.permit(:option_text, :additional_info)) if option
      end
    end
  
    # Delete specified options
    if options_params[:to_delete]
      poll.options.where(id: options_params[:to_delete]).destroy_all
    end
  end

end