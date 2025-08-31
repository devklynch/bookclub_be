class Api::V1::BookClubsController < ApplicationController
  before_action :authenticate_user!

  def show
    user = User.find(params[:user_id])
    book_club = BookClub.find(params[:id])
    if user.book_clubs.include?(book_club)
      render json: BookClubSerializer.new(book_club, params: { current_user: current_user }), status: :ok
    else
      render json: ErrorSerializer.format_errors(["You are not authorized to view this book club"]), status: :forbidden
    end
  end
  
  def create
    book_club = BookClub.new(book_club_params)
    
    ActiveRecord::Base.transaction do
      if book_club.save
        # Add creator as member
        book_club.users << current_user
        # Make the creator an admin
        book_club.book_club_admins.create!(user: current_user)
        
        render json: BookClubSerializer.new(book_club, params: { current_user: current_user }), status: :created
      else
        render json: ErrorSerializer.format_errors(book_club.errors.full_messages), status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: ErrorSerializer.format_errors([e.message]), status: :unprocessable_entity
  end

  def update
    book_club = BookClub.find(params[:id])

    unless book_club.admin?(current_user)
      return render json: ErrorSerializer.format_errors(["Only admins can edit book clubs"]), status: :forbidden
    end

    if book_club.update(book_club_params)
      render json: BookClubSerializer.new(book_club, params: { current_user: current_user }), status: :ok
    else
      render json: ErrorSerializer.format_errors(book_club.errors.full_messages), status: :unprocessable_entity
    end
  end

  private

  def book_club_params
    params.require(:book_club).permit(:name, :description)
  end

end