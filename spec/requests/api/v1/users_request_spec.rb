require 'rails_helper'

RSpec.describe "User endpoints", type: :request do
  before :each do
    @user1 = create(:user)
    @user2 = create(:user)

    @book_club1 = create(:book_club)
    @book_club2 = create(:book_club)

    Member.create!(user: @user1, book_club: @book_club1)
    Member.create!(user: @user2, book_club: @book_club1)

    @poll1 = create(:poll, poll_question: "Next book?", expiration_date: Date.today + 1.week, book_club_id: @book_club1.id)
    @poll2 = create(:poll, book_club: @book_club1)
    @poll3 = create(:poll, book_club: @book_club2)

    @option1 = create(:option, option_text: "Gone Girl", additional_info: "Thriller", poll: @poll1)
    @option2 = create(:option, option_text: "Sherlock Holmes", additional_info: "Classic", poll: @poll1)

    create(:vote, option: @option1, user: @user1)
    create(:vote, option: @option1, user: @user2)
    create(:vote, option: @option2, user: @user1)
    @token1 = @user1.generate_jwt
  end

  describe "Show all club data for a user" do
    it "should show a user's data including book clubs, events, and polls" do
      get all_club_data_api_v1_user_path(id:@user1.id), headers: { 'Authorization' => "Bearer #{@token1}" }

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response.status).to eq(200)
      expect(json[:data][:id]).to eq(@user1.id.to_s)
      expect(json[:data][:type]).to eq("all_club_data")
      expect(json[:data][:attributes][:id]).to eq(@user1.id)
      expect(json[:data][:attributes][:display_name]).to eq(@user1.display_name)
      expect(json[:data][:attributes][:book_clubs].count).to eq(1)
      expect(json[:data][:attributes][:book_clubs][0][:id]).to eq(@book_club1.id)
      expect(json[:data][:attributes][:book_clubs][0][:name]).to eq(@book_club1.name)
      expect(json[:data][:attributes][:upcoming_events]).to eq([])
      expect(json[:data][:attributes][:active_polls].count).to eq(1)
      expect(json[:data][:attributes][:active_polls][0][:id]).to eq(@poll1.id)
      expect(json[:data][:attributes][:active_polls][0][:question]).to eq(@poll1.poll_question)
    end

    it "should give an error if the token is not associated with that user" do
      get all_club_data_api_v1_user_path(id:@user2.id), headers: { 'Authorization' => "Bearer #{@token1}" }

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:forbidden)
      expect(json[:error]).to eq("You are not authorized to perform this action")
    end
  end

  describe "Show all book clubs for a user" do
    it "should show all book clubs that a user is a member of" do
      get book_clubs_api_v1_user_path(id: @user1.id), headers: { 'Authorization' => "Bearer #{@token1}" }

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response.status).to eq(200)
      expect(json[:data]).to be_an(Array)
      expect(json[:data].count).to eq(1)
      expect(json[:data][0][:id]).to eq(@book_club1.id.to_s)
      expect(json[:data][0][:type]).to eq("book_club")
      expect(json[:data][0][:attributes][:name]).to eq(@book_club1.name)
      expect(json[:data][0][:attributes][:description]).to eq(@book_club1.description)
    end

    it "should give an error if the token is not associated with that user" do
      get book_clubs_api_v1_user_path(id: @user2.id), headers: { 'Authorization' => "Bearer #{@token1}" }

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:forbidden)
      expect(json[:error]).to eq("You are not authorized to perform this action")
    end
  end

  describe "Show all events for a user" do
    before :each do
      @event1 = create(:event, event_name: "Book Discussion", event_date: Date.today + 1.week, book_club: @book_club1)
      @event2 = create(:event, event_name: "Past Meeting", event_date: Date.today - 1.week, book_club: @book_club1)
      @event3 = create(:event, event_name: "Future Meeting", event_date: Date.today + 2.weeks, book_club: @book_club1)
      
      Attendee.create!(user: @user1, event: @event1, attending: true)
      Attendee.create!(user: @user1, event: @event2, attending: false)
      Attendee.create!(user: @user1, event: @event3, attending: true)
    end

    it "should show upcoming and past events for a user" do
      get events_api_v1_user_path(id: @user1.id), headers: { 'Authorization' => "Bearer #{@token1}" }

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response.status).to eq(200)
      expect(json[:data][:upcoming_events]).to be_an(Array)
      expect(json[:data][:past_events]).to be_an(Array)
      expect(json[:data][:upcoming_events].count).to be >= 2
      expect(json[:data][:past_events].count).to be >= 1
      
      # Check that we have the expected event names in the arrays
      upcoming_event_names = json[:data][:upcoming_events].map { |event| event[:attributes][:event_name] }
      past_event_names = json[:data][:past_events].map { |event| event[:attributes][:event_name] }
      
      expect(upcoming_event_names).to include("Book Discussion", "Future Meeting")
      expect(past_event_names).to include("Past Meeting")
    end

    it "should give an error if the token is not associated with that user" do
      get events_api_v1_user_path(id: @user2.id), headers: { 'Authorization' => "Bearer #{@token1}" }

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:forbidden)
      expect(json[:error]).to eq("You are not authorized to perform this action")
    end
  end

  describe "Show all polls for a user" do
    before :each do
      @poll1 = create(:poll, poll_question: "Active Poll", expiration_date: Date.today + 1.week, book_club: @book_club1)
      @poll2 = create(:poll, poll_question: "Expired Poll", expiration_date: Date.today - 1.week, book_club: @book_club1)
      @poll3 = create(:poll, poll_question: "Another Active Poll", expiration_date: Date.today + 2.weeks, book_club: @book_club1)
    end

    it "should show active and expired polls for a user" do
      get polls_api_v1_user_path(id: @user1.id), headers: { 'Authorization' => "Bearer #{@token1}" }

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response.status).to eq(200)
      expect(json[:data][:active_polls]).to be_an(Array)
      expect(json[:data][:expired_polls]).to be_an(Array)
      expect(json[:data][:active_polls].count).to be >= 2
      expect(json[:data][:expired_polls].count).to be >= 1
      
      # Check that we have the expected poll questions in the arrays
      active_poll_questions = json[:data][:active_polls].map { |poll| poll[:attributes][:poll_question] }
      expired_poll_questions = json[:data][:expired_polls].map { |poll| poll[:attributes][:poll_question] }
      
      expect(active_poll_questions).to include("Active Poll", "Another Active Poll")
      expect(expired_poll_questions).to include("Expired Poll")
    end

    it "should give an error if the token is not associated with that user" do
      get polls_api_v1_user_path(id: @user2.id), headers: { 'Authorization' => "Bearer #{@token1}" }

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:forbidden)
      expect(json[:error]).to eq("You are not authorized to perform this action")
    end
  end
end