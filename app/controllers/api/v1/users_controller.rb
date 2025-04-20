class Api::V1::UsersController < ApplicationController
  before_action :authenticate_user!

  def all_club_data
    user = User.find(params[:id])
 
    authorize user, :all_club_data?

    render json: AllClubDataSerializer.new(user), status: :ok

  end
end