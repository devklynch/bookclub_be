class BookClubSerializer
  include JSONAPI::Serializer
  attributes :name, :description

  attribute :members do |book_club|
    book_club.members.map do |member|
      {
        id: member.id,
        user_id: member.user_id,
        email: member.user.email,
        display_name: member.user.display_name
    }
  end
end
  attribute :events do |book_club|
    book_club.events.map do |event|
      {
        id: event.id,
        event_name: event.event_name,
        event_date: event.event_date,
        location: event.location,
        book: event.book,
        event_notes: event.event_notes
      }
    end
  end
  attribute :polls do |book_club|
    book_club.polls.map do |poll|
      {
        id: poll.id,
        poll_question: poll.poll_question,
        expiration_date: poll.expiration_date,
        book_club_id: poll.book_club_id
      }
    end
  end
end