class EventSerializer
    include JSONAPI::Serializer
    attributes :event_name, :event_date, :location, :book, :event_notes, :book_club_id

    attribute :user_is_attending do |event, params|
        current_user = params[:current_user]
        event.attendees.exists?(user_id: current_user)
    end

    attribute :attendees do |event|
        event.attendees.map do |attendee|
            {
                id: attendee.user_id,
                attendee_id: attendee.id,
                name: attendee.user.display_name,
                attending: attendee.attending
            }
        end
    end
end