class EventSerializer
    include JSONAPI::Serializer
    attributes :event_name, :event_date, :location, :book, :event_notes, :book_club_id
end