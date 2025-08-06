class Api::V1::BookClubsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!

  def show
    user = User.find(params[:user_id])
    book_club = BookClub.find(params[:id])
    if user.book_clubs.include?(book_club)
      render json: BookClubSerializer.new(book_club), status: :ok
    else
      render json: ErrorSerializer.format_errors(["You are not authorized to view this book club"]), status: :forbidden
    end
  end
  
  def create
    book_club = BookClub.new(book_club_params)
    book_club.users << current_user  # Add creator as member

    if book_club.save
      render json: BookClubSerializer.new(book_club), status: :created
    else
      render json: ErrorSerializer.format_errors(book_club.errors.full_messages), status: :unprocessable_entity
    end
  end

  def update
    book_club = BookClub.find(params[:id])

    unless book_club.users.include?(current_user)
      return render json: ErrorSerializer.format_errors(["Not authorized"]), status: :forbidden
    end

    if book_club.update(book_club_params)
      render json: BookClubSerializer.new(book_club), status: :ok
    else
      render json: ErrorSerializer.format_errors(book_club.errors.full_messages), status: :unprocessable_entity
    end
  end

  private

  def book_club_params
    params.require(:book_club).permit(:name, :description)
  end

end