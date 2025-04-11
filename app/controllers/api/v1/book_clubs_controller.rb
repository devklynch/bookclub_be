class Api::V1::BookClubsController < ApplicationController
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
end