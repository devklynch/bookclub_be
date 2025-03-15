class Api::V1::EventsController < ApplicationController

    def show
        user = User.find(params[:user_id])
        event = Event.find(params[:id])

        if user.book_clubs.include?(event.book_club)
            render json: event
        else
            render json: {error: "Test Error"}
        end
    end
end