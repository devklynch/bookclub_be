class Api::V1::AttendeesController < ApplicationController

  before_action :authenticate_user!


  def update
    event = Event.find(params[:event_id])
    attendee = event.attendees.find_by(user: current_user)

    if attendee.update(attendee_params)
      render json: {message: "RSVP updated", attending: attendee.attending}, status: :ok
    else
      render json: ErrorSerializer.format_errors(attendee.errors.full_messages), status: :unprocessable_entity
    end
  end

  private

  def attendee_params
    params.require(:attendee).permit(:attending)
  end
end