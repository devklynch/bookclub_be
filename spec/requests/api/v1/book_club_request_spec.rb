require 'rails_helper'

RSpec.describe "Book Club endpoints", :type => :request do
  before :each do
    @user1 = create(:user)
    @user2 = create(:user)

    @book_club1 = create(:book_club)
    @book_club2 = create(:book_club)

    Member.create!(user: @user1, book_club: @book_club1)
    Member.create!(user: @user2, book_club: @book_club1)
    Member.create!(user: @user2, book_club: @book_club2)

    @token1 = @user1.generate_jwt
  end

  describe "Show one book club" do
    it "should show a book club and its attributes" do
      get api_v1_user_book_club_path(user_id: @user1.id, id: @book_club1.id), headers: { 'Authorization' => "Bearer #{@token1}" }

      book_club = JSON.parse(response.body, symbolize_names: true)

      expect(response.status).to eq(200)
      expect(book_club[:data][:id]).to eq(@book_club1.id.to_s)
      expect(book_club[:data][:type]).to eq("book_club")
      expect(book_club[:data][:attributes][:name]).to eq(@book_club1.name)
      expect(book_club[:data][:attributes][:description]).to eq(@book_club1.description)
      expect(book_club[:data][:attributes]).to have_key(:events)
      expect(book_club[:data][:attributes]).to have_key(:polls)
      expect(book_club[:data][:attributes][:members].count).to eq(2)
    end

    it "should give an error if the user id does not exist" do
      get api_v1_user_book_club_path(user_id: 9999999, id: @book_club1.id), headers: { 'Authorization' => "Bearer #{@token1}" }

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:not_found)
      expect(json[:errors][0][:message]).to eq("Couldn't find User with 'id'=9999999")
    end

    it "should gave an error if the user does not have access to a bookclub" do
      get api_v1_user_book_club_path(user_id: @user1.id, id: @book_club2.id), headers: { 'Authorization' => "Bearer #{@token1}" }
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:forbidden)
      expect(json[:errors][0][:message]).to eq("You are not authorized to view this book club")
    end
  end
end