require 'rails_helper'

RSpec.describe "Poll endpoints", type: :request do
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

  describe "Show one poll" do
    it "should show a poll and its attributes" do
      get api_v1_user_poll_path(user_id: @user1.id, id: @poll1.id), headers: { 'Authorization' => "Bearer #{@token1}" }

      poll = JSON.parse(response.body, symbolize_names: true)

      expect(response.status).to eq(200)
      expect(poll[:data][:id]).to eq(@poll1.id.to_s)
      expect(poll[:data][:type]).to eq("poll")
      expect(poll[:data][:attributes][:poll_question]).to eq(@poll1.poll_question)
      expect(poll[:data][:attributes]).to have_key(:expiration_date)
      expect(poll[:data][:attributes][:book_club_id]).to eq(@book_club1.id)
      expect(poll[:data][:attributes][:book_club_name]).to eq(@book_club1.name)

      expect(poll[:data][:attributes][:options].count).to eq(2)

      gone_girl = poll[:data][:attributes][:options].find { |opt| opt[:option_text] == "Gone Girl" }
      sherlock = poll[:data][:attributes][:options].find { |opt| opt[:option_text] == "Sherlock Holmes" }

      expect(gone_girl[:additional_info]).to eq("Thriller")
      expect(gone_girl[:votes_count]).to eq(2)

      expect(sherlock[:additional_info]).to eq("Classic")
      expect(sherlock[:votes_count]).to eq(1)
    end

    it "should give an error if the user id does not exist" do
      get api_v1_user_poll_path(user_id: 9999999, id: @poll1.id), headers: { 'Authorization' => "Bearer #{@token1}" }

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:not_found)
      expect(json[:errors][0][:message]).to eq("Couldn't find User with 'id'=9999999")
    end

    it "should give an error if the poll id does not exist" do
      get api_v1_user_poll_path(user_id: @user1.id, id: 9999999), headers: { 'Authorization' => "Bearer #{@token1}" }

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:not_found)
      expect(json[:errors][0][:message]).to eq("Couldn't find Poll with 'id'=9999999")
    end

    it "should give a forbidden error if the user doesn't have access to an event" do
      get api_v1_user_poll_path(user_id: @user1.id, id: @poll3.id), headers: { 'Authorization' => "Bearer #{@token1}" }

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:forbidden)
      expect(json[:errors][0][:message]).to eq("You are not authorized to view this poll")
    end

    it "should return an error if a token is not included" do
      get api_v1_user_poll_path(user_id: @user1.id, id: @poll1.id)

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:unauthorized)
      expect(json[:errors][0][:message]).to eq("Token is missing")
    end

    it "should return an error with an invalid token" do
      get api_v1_user_poll_path(user_id: @user1.id, id: @poll1.id), headers: { 'Authorization' => "Bearer invalid_token" }
      json = JSON.parse(response.body, symbolize_names: true)
      expect(response).to have_http_status(:unauthorized)
      expect(json[:errors][0][:message]).to eq("Invalid or expired token")
    end
  end
end