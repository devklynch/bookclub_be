# # This file should ensure the existence of records required to run the application in every environment (production,
# # development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# # The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
# #
# # Example:
# #
# #   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
# #     MovieGenre.find_or_create_by!(name: genre_name)
# #   end
# require 'faker'

# # Clear existing data
# Vote.destroy_all
# Option.destroy_all
# Poll.destroy_all
# Attendee.destroy_all
# Event.destroy_all
# Member.destroy_all
# BookClub.destroy_all
# User.destroy_all

# # Create Users
# users = 10.times.map do 
#   User.create!(
#     email: Faker::Internet.unique.email,
#     password: "password",
#     display_name: Faker::Book.author
#   )
# end

# # Create Book Clubs
# book_clubs = 3.times.map do 
#   BookClub.create!(
#     name: Faker::Book.genre + " Enthusiasts",
#     description: Faker::Lorem.sentence
#   )
# end

# # Assign users to book clubs as members
# book_clubs.each do |book_club|
#   users.sample(5).each do |user|
#     Member.create!(user: user, book_club: book_club)
#   end
# end

# # Create Events
# events = book_clubs.flat_map do |book_club|
#   2.times.map do
#     Event.create!(
#       event_name: "Discussion on " + Faker::Book.title,
#       event_date: Faker::Date.forward(days: 30),
#       location: Faker::Address.city,
#       book: Faker::Book.title,
#       event_notes: Faker::Lorem.sentence,
#       book_club: book_club
#     )
#   end
# end

# # Create Attendees for Events
# events.each do |event|
#   event.book_club.members.sample(3).each do |member|
#     Attendee.create!(user: member.user, event: event, attending: [true, false].sample)
#   end
# end

# # Create Polls
# polls = book_clubs.flat_map do |book_club|
#   2.times.map do
#     Poll.create!(
#       poll_question: "What book should we read next?",
#       expiration_date: Faker::Date.forward(days: 15),
#       book_club: book_club
#     )
#   end
# end

# # Create Poll Options
# options = polls.flat_map do |poll|
#   3.times.map do
#     Option.create!(
#       option_text: Faker::Book.title,
#       poll: poll
#     )
#   end
# end

# # Create Votes
# options.each do |option|
#   option.poll.book_club.members.sample(3).each do |member|
#     Vote.create!(user: member.user, option: option)
#   end
# end

# puts "Seeding complete!"

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

# Create 2-3 attendees per event
Event.all.each do |event|
  members = event.book_club.members.map(&:user).sample(3)
  members.each do |user|
    Attendee.create!(
      user: user,
      event: event,
      attending: [true, false].sample
    )
  end
end

puts "✅ Seeding complete!"