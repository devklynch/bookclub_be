require 'rails_helper'

RSpec.describe "Event endpoints", :type => :request do
  before :each do
    @user1 = create(:user)
    @user2 = create(:user)

    @book_club1 = create(:book_club)
    @book_club2 = create(:book_club)

    Member.create!(user: @user1, book_club: @book_club1)

    @event1 = create(:event, book_club: @book_club1)
    @event2 = create(:event, book_club: @book_club1)
    @event3 = create(:event, book_club: @book_club2)

    @token1 = @user1.generate_jwt
  end

  describe "Show one event" do
    it "should show an event an it's attributes" do
      get api_v1_user_event_path(user_id: @user1.id, id: @event1.id), headers: { 'Authorization' => "Bearer #{@token1}" }

      event = JSON.parse(response.body, symbolize_names: true)

      expect(response.status).to eq(200)
      expect(event[:data][:id]).to eq(@event1.id.to_s)
      expect(event[:data][:type]).to eq("event")
      expect(event[:data][:attributes][:event_name]).to eq(@event1.event_name)
      expect(event[:data][:attributes]).to have_key(:event_date)
      expect(event[:data][:attributes][:location]).to eq(@event1.location)
      expect(event[:data][:attributes][:book]).to eq(@event1.book)
      expect(event[:data][:attributes][:event_notes]).to eq(@event1.event_notes)
      expect(event[:data][:attributes][:book_club_id]).to eq(@book_club1.id)
    end

    it "should give an error if the user id does not exist" do
    get api_v1_user_event_path(user_id: 9999999, id: @event1.id), headers: { 'Authorization' => "Bearer #{@token1}" }

    json = JSON.parse(response.body, symbolize_names: true)

    expect(response).to have_http_status(:not_found)
    expect(json[:errors][0][:message]).to eq("Couldn't find User with 'id'=9999999")
    end

    it "should give an error if the event id does not exist" do
      get api_v1_user_event_path(user_id: @user1.id, id:9999999 ), headers: { 'Authorization' => "Bearer #{@token1}" }

      json = JSON.parse(response.body, symbolize_names: true)
  
      expect(response).to have_http_status(:not_found)
      expect(json[:errors][0][:message]).to eq("Couldn't find Event with 'id'=9999999")
    end

    it "should give a forbidden error if the user doesn't have access to an event" do
      get api_v1_user_event_path(user_id: @user1.id, id:@event3.id ), headers: { 'Authorization' => "Bearer #{@token1}" }

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:forbidden)
      expect(json[:errors][0][:message]).to eq("You are not authorized to view this event")
    end
  end
end