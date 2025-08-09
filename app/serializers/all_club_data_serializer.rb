class AllClubDataSerializer
  include JSONAPI::Serializer


  attributes :id, :display_name

 # Show the first 5 book clubs the user is a part of
 attribute :book_clubs do |user|
  user.book_clubs.limit(5).map do |club|
    {
      id: club.id,
      name: club.name,
      description: club.description
    }
  end
end

# Show the 5 closest upcoming events associated with the user's book clubs
attribute :upcoming_events do |user|
  Event.joins(book_club: :members)
    .where('events.event_date >= ?', Date.today)
    .where(book_clubs: { id: user.book_club_ids })
    .distinct
    .order(:event_date)
    .limit(5)
    .map do |event|
      attendee = event.attendees.find { |a| a.user_id == user.id }
  
    {
      id: event.id,
      event_name: event.event_name,
      event_date: event.event_date,
      location: event.location,
      book: event.book,
      attending: attendee&.attending,
      book_club: {
        id: event.book_club.id,
        name: event.book_club.name
      }
    }
  end
end

# Show the 5 polls closest to expiring from the user's book clubs
attribute :active_polls do |user|
  Poll.joins(:book_club)
      .where('polls.expiration_date >= ?', Date.today)
      .where(book_clubs: { id: user.book_club_ids })
      .distinct
      .order(:expiration_date)
      .limit(5)
      .map do |poll|
    {
      id: poll.id,
      poll_question: poll.poll_question,
      expiration_date: poll.expiration_date,
      multiple_votes: poll.multiple_votes,
      book_club: {
        id: poll.book_club.id,
        name: poll.book_club.name
      }
    }
  end
end
end