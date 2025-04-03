# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
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

# Create Users
users = 10.times.map do 
  User.create!(
    email: Faker::Internet.unique.email,
    password: "password",
    display_name: Faker::Book.author
  )
end

# Create Book Clubs
book_clubs = 3.times.map do 
  BookClub.create!(
    name: Faker::Book.genre + " Enthusiasts",
    description: Faker::Lorem.sentence
  )
end

# Assign users to book clubs as members
book_clubs.each do |book_club|
  users.sample(5).each do |user|
    Member.create!(user: user, book_club: book_club)
  end
end

# Create Events
events = book_clubs.flat_map do |book_club|
  2.times.map do
    Event.create!(
      event_name: "Discussion on " + Faker::Book.title,
      event_date: Faker::Date.forward(days: 30),
      location: Faker::Address.city,
      book: Faker::Book.title,
      event_notes: Faker::Lorem.sentence,
      book_club: book_club
    )
  end
end

# Create Attendees for Events
events.each do |event|
  event.book_club.members.sample(3).each do |member|
    Attendee.create!(user: member.user, event: event, attending: [true, false].sample)
  end
end

# Create Polls
polls = book_clubs.flat_map do |book_club|
  2.times.map do
    Poll.create!(
      poll_question: "What book should we read next?",
      expiration_date: Faker::Date.forward(days: 15),
      book_club: book_club
    )
  end
end

# Create Poll Options
options = polls.flat_map do |poll|
  3.times.map do
    Option.create!(
      option_text: Faker::Book.title,
      poll: poll
    )
  end
end

# Create Votes
options.each do |option|
  option.poll.book_club.members.sample(3).each do |member|
    Vote.create!(user: member.user, option: option)
  end
end

puts "Seeding complete!"