class PollSerializer

#add a way to show the book club name in the poll serializer
  include JSONAPI::Serializer
  attributes :poll_question, :expiration_date, :book_club_id, :multiple_votes

  attribute :book_club_name do |poll|
    poll.book_club.name
  end
  attribute :options do |poll|
    poll.options.map do |option|
      {
        id: option.id,
        option_text: option.option_text,
        additional_info: option.additional_info,
        votes_count: option.votes.count
      }
    end
  end
end