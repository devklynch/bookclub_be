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
end