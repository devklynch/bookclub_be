

require 'faker'

# Clear existing data
Vote.destroy_all
Option.destroy_all
Poll.destroy_all
Attendee.destroy_all
Event.destroy_all
Member.destroy_all
BookClub.destroy_all
User.destroy_all

# Create static users
users = 15.times.map do |i|
  User.create!(
    email: "user#{i + 1}@bookclub.com",
    password: "password",
    display_name: "User #{i + 1}"
  )
end

# Create static book clubs
book_clubs = 5.times.map do |i|
  BookClub.create!(
    name: "Book Club #{i + 1}",
    description: "This is the description for Book Club #{i + 1}"
  )
end

# Assign 3 unique members to each book club
book_clubs.each_with_index do |book_club, index|
  members = users.slice(index * 3, 3)
  members.each do |user|
    Member.create!(user: user, book_club: book_club)
  end
end

# Create events (2 future, 1 past) per club
book_clubs.each_with_index do |book_club, i|
  [
    { name: "Past Event", days_offset: -10 },
    { name: "Upcoming Event 1", days_offset: 100 },
    { name: "Upcoming Event 2", days_offset: 120 }
  ].each_with_index do |event_data, j|
    Event.create!(
      event_name: "#{event_data[:name]} - Club #{i + 1}",
      event_date: Date.today + event_data[:days_offset],
      location: "City #{i + 1}",
      book: "Book #{j + 1} for Club #{i + 1}",
      event_notes: "Notes for #{event_data[:name]}",
      book_club: book_club
    )
  end
end

# Create polls (2 active, 1 expired) per club
book_clubs.each_with_index do |book_club, i|
  [
    { question: "Expired Poll", days_offset: -5 },
    { question: "Current Poll 1", days_offset: 100 },
    { question: "Current Poll 2", days_offset: 120 }
  ].each do |poll_data|
    Poll.create!(
      poll_question: "#{poll_data[:question]} - Club #{i + 1}",
      expiration_date: Date.today + poll_data[:days_offset],
      multiple_votes: true,
      book_club: book_club
    )
  end
end

# Create 3 options for each poll
Poll.all.each_with_index do |poll, i|
  3.times do |j|
    Option.create!(
      option_text: "Option #{j + 1} for #{poll.poll_question}",
      poll: poll
    )
  end
end

# Create 2 votes per option from members of the poll's book club
Option.all.each do |option|
  members = option.poll.book_club.members.map(&:user).sample(2)
  members.each do |user|
    Vote.create!(user: user, option: option)
  end
end

Event.all.each do |event|
  event.book_club.members.each do |member|
    Attendee.find_or_create_by!(
      user: member.user,
      event: event
    ) do |attendee|
      attendee.attending = [true, false, nil].sample # Optional: random status or always nil
    end
  end
end

puts "✅ Seeding complete!"