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


    @poll1.options.destroy_all
    @option1 = create(:option, option_text: "Gone Girl", additional_info: "Thriller", poll: @poll1)
    @option2 = create(:option, option_text: "Sherlock Holmes", additional_info: "Classic", poll: @poll1)

    create(:vote, option: @option1, user: @user1)
    create(:vote, option: @option1, user: @user2)
    create(:vote, option: @option2, user: @user1)
    @token1 = @user1.generate_jwt
  end

  describe "Show all club data for a user" do
    context "successful requests" do
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
        expect(json[:data][:attributes][:book_clubs][0][:description]).to eq(@book_club1.description)
        expect(json[:data][:attributes][:upcoming_events]).to eq([])
        expect(json[:data][:attributes][:active_polls].count).to eq(2)
        expect(json[:data][:attributes][:active_polls][0][:id]).to eq(@poll1.id)
        expect(json[:data][:attributes][:active_polls][0][:poll_question]).to eq(@poll1.poll_question)
      end

      it "should limit book clubs to 5 when user has many clubs" do
        (1..6).each do |i|
          book_club = create(:book_club, name: "Book Club #{i}")
          Member.create!(user: @user1, book_club: book_club)
        end

        get all_club_data_api_v1_user_path(id:@user1.id), headers: { 'Authorization' => "Bearer #{@token1}" }

        json = JSON.parse(response.body, symbolize_names: true)

        expect(response.status).to eq(200)
        expect(json[:data][:attributes][:book_clubs].count).to eq(5)
      end

      it "should include upcoming events with attendee status when available" do
        event = create(:event, 
          event_name: "Future Book Discussion", 
          event_date: Date.today + 1.week, 
          location: "Library",
          book: "The Great Gatsby",
          book_club: @book_club1
        )
        event.attendees.find_by(user: @user1).update!(attending: true)

        get all_club_data_api_v1_user_path(id:@user1.id), headers: { 'Authorization' => "Bearer #{@token1}" }

        json = JSON.parse(response.body, symbolize_names: true)

        expect(response.status).to eq(200)
        expect(json[:data][:attributes][:upcoming_events].count).to eq(1)
        
        event_data = json[:data][:attributes][:upcoming_events][0]
        expect(event_data[:id]).to eq(event.id)
        expect(event_data[:event_name]).to eq("Future Book Discussion")
        expect(event_data[:location]).to eq("Library")
        expect(event_data[:book]).to eq("The Great Gatsby")
        expect(event_data[:attending]).to eq(true)
        expect(event_data[:book_club][:id]).to eq(@book_club1.id)
        expect(event_data[:book_club][:name]).to eq(@book_club1.name)
      end

      it "should limit upcoming events to 5 when user has many events" do
        (1..6).each do |i|
          create(:event, 
            event_name: "Event #{i}", 
            event_date: Date.today + i.days, 
            book_club: @book_club1
          )
        end

        get all_club_data_api_v1_user_path(id:@user1.id), headers: { 'Authorization' => "Bearer #{@token1}" }

        json = JSON.parse(response.body, symbolize_names: true)

        expect(response.status).to eq(200)
        expect(json[:data][:attributes][:upcoming_events].count).to eq(5)
        
        # Verify that only the first 5 events (closest dates) are included
        event_names = json[:data][:attributes][:upcoming_events].map { |e| e[:event_name] }
        expect(event_names).to include("Event 1", "Event 2", "Event 3", "Event 4", "Event 5")
        expect(event_names).not_to include("Event 6")
      end

      it "should limit active polls to 5 when user has many polls" do
        (1..6).each do |i|
          create(:poll, 
            poll_question: "Poll #{i}?", 
            expiration_date: Date.today + i.days, 
            book_club: @book_club1
          )
        end

        get all_club_data_api_v1_user_path(id:@user1.id), headers: { 'Authorization' => "Bearer #{@token1}" }

        json = JSON.parse(response.body, symbolize_names: true)

        expect(response.status).to eq(200)
        expect(json[:data][:attributes][:active_polls].count).to eq(5)
        
        poll_questions = json[:data][:attributes][:active_polls].map { |p| p[:poll_question] }
        expect(poll_questions).to include("Poll 1?", "Poll 2?", "Poll 3?", "Poll 4?", "Poll 5?")
        expect(poll_questions).not_to include("Poll 6?")
      end

      it "should include poll book club information" do
        get all_club_data_api_v1_user_path(id:@user1.id), headers: { 'Authorization' => "Bearer #{@token1}" }

        json = JSON.parse(response.body, symbolize_names: true)

        expect(response.status).to eq(200)
        
        poll_data = json[:data][:attributes][:active_polls][0]
        expect(poll_data[:book_club][:id]).to eq(@book_club1.id)
        expect(poll_data[:book_club][:name]).to eq(@book_club1.name)
      end

      it "should only show events from user's book clubs" do
        other_book_club = create(:book_club, name: "Other Club")
        other_event = create(:event, 
          event_name: "Other Event", 
          event_date: Date.today + 1.week, 
          book_club: other_book_club
        )

        user_event = create(:event, 
          event_name: "User Event", 
          event_date: Date.today + 1.week, 
          book_club: @book_club1
        )

        get all_club_data_api_v1_user_path(id:@user1.id), headers: { 'Authorization' => "Bearer #{@token1}" }

        json = JSON.parse(response.body, symbolize_names: true)

        expect(response.status).to eq(200)
        
        event_names = json[:data][:attributes][:upcoming_events].map { |e| e[:event_name] }
        expect(event_names).to include("User Event")
        expect(event_names).not_to include("Other Event")
      end

      it "should only show polls from user's book clubs" do
        other_book_club = create(:book_club, name: "Other Club")
        other_poll = create(:poll, 
          poll_question: "Other Poll?", 
          expiration_date: Date.today + 1.week, 
          book_club: other_book_club
        )

        get all_club_data_api_v1_user_path(id:@user1.id), headers: { 'Authorization' => "Bearer #{@token1}" }

        json = JSON.parse(response.body, symbolize_names: true)

        expect(response.status).to eq(200)
        
        poll_questions = json[:data][:attributes][:active_polls].map { |p| p[:poll_question] }
        expect(poll_questions).to include("Next book?")
        expect(poll_questions).not_to include("Other Poll?")
      end
    end

    context "edge cases" do
      it "should return empty arrays when user has no book clubs" do
        user_no_clubs = create(:user)
        token_no_clubs = user_no_clubs.generate_jwt

        get all_club_data_api_v1_user_path(id: user_no_clubs.id), headers: { 'Authorization' => "Bearer #{token_no_clubs}" }

        json = JSON.parse(response.body, symbolize_names: true)

        expect(response.status).to eq(200)
        expect(json[:data][:attributes][:book_clubs]).to eq([])
        expect(json[:data][:attributes][:upcoming_events]).to eq([])
        expect(json[:data][:attributes][:active_polls]).to eq([])
      end

      it "should handle events without attendee records gracefully" do
        event_without_attendee = create(:event, 
          event_name: "No Attendee Event", 
          event_date: Date.today + 1.week, 
          book_club: @book_club1
        )

        get all_club_data_api_v1_user_path(id:@user1.id), headers: { 'Authorization' => "Bearer #{@token1}" }

        json = JSON.parse(response.body, symbolize_names: true)

        expect(response.status).to eq(200)
        
        event_data = json[:data][:attributes][:upcoming_events].find { |e| e[:event_name] == "No Attendee Event" }
        expect(event_data).not_to be_nil
        expect(event_data[:attending]).to be_nil
      end
    end

    context "authorization" do
      it "should give an error if the token is not associated with that user" do
        get all_club_data_api_v1_user_path(id:@user2.id), headers: { 'Authorization' => "Bearer #{@token1}" }

        json = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:forbidden)
        expect(json[:errors][0][:message]).to eq("You are not authorized to perform this action")
      end

      it "should give an error if no authentication token is provided" do
        get all_club_data_api_v1_user_path(id:@user1.id)

        json = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:unauthorized)
        expect(json[:errors][0][:message]).to eq("Token is missing")
      end

      it "should give an error if an invalid token is provided" do
        get all_club_data_api_v1_user_path(id:@user1.id), headers: { 'Authorization' => "Bearer invalid_token" }

        json = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:unauthorized)
        expect(json[:errors][0][:message]).to eq("Invalid or expired token")
      end

      it "should give an error if user does not exist" do
        get all_club_data_api_v1_user_path(id: 999999), headers: { 'Authorization' => "Bearer #{@token1}" }

        json = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:not_found)
        expect(json[:errors][0][:message]).to include("Couldn't find User")
      end
    end

    context "data ordering" do
      it "should order upcoming events by event_date" do
        event1 = create(:event, event_name: "Later Event", event_date: Date.today + 2.weeks, book_club: @book_club1)
        event2 = create(:event, event_name: "Earlier Event", event_date: Date.today + 1.week, book_club: @book_club1)

        get all_club_data_api_v1_user_path(id:@user1.id), headers: { 'Authorization' => "Bearer #{@token1}" }

        json = JSON.parse(response.body, symbolize_names: true)

        expect(response.status).to eq(200)
        event_names = json[:data][:attributes][:upcoming_events].map { |e| e[:event_name] }
        expect(event_names.first).to eq("Earlier Event")
      end

      it "should order active polls by expiration_date" do
        poll1 = create(:poll, poll_question: "Later Poll?", expiration_date: Date.today + 2.weeks, book_club: @book_club1)
        poll2 = create(:poll, poll_question: "Earlier Poll?", expiration_date: Date.today + 3.days, book_club: @book_club1)

        get all_club_data_api_v1_user_path(id:@user1.id), headers: { 'Authorization' => "Bearer #{@token1}" }

        json = JSON.parse(response.body, symbolize_names: true)

        expect(response.status).to eq(200)
        poll_questions = json[:data][:attributes][:active_polls].map { |p| p[:poll_question] }
        expect(poll_questions.first).to eq("Earlier Poll?")
      end
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
      expect(json[:errors][0][:message]).to eq("You are not authorized to perform this action")
    end
  end
end