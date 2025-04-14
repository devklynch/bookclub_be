class Api::V1::UsersController < ApplicationController
  before_action :authenticate_user!

  def all_club_data
    user = User.find(params[:id])
    
    render json: AllClubDataSerializer.new(user), status: :ok

  end
end