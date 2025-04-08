require 'rails_helper'

RSpec.describe "User Registration", type: :request do
  let(:user_params) do
    {
      email: "test@test.com",
      password: "password",
      password_confirmation: "password",
      display_name: "Test User"
    }
  end

  before :each do
    @user = create(:user)
  end

  describe "POST /api/v1/users" do
    it "creates a new user" do
      post api_v1_users_path, params: {
        user: user_params
      }

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:created)
      expect(json[:data][:id]).to eq(User.last.id.to_s)
      expect(json[:data][:type]).to eq("user")
      expect(json[:data][:attributes][:email]).to eq(user_params[:email])
      expect(json[:data][:attributes][:display_name]).to eq(user_params[:display_name])
      expect(json[:data][:attributes][:password]).to be_nil
      expect(json[:data][:attributes][:password_confirmation]).to be_nil
    end

    it "returns an error when the email is already in use" do
      post api_v1_users_path, params: {  
        user: {
        email: @user.email,
        password: "password",
        password_confirmation: "password",
        display_name: "Test User"
      }}

      json = JSON.parse(response.body, symbolize_names: true)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:errors][0][:message]).to eq("Email has already been taken")
    end

    it "returns an error when a required field is missing" do
      post api_v1_users_path, params: {
        user: {
          email: "",
          password: "password",
          password_confirmation: "password",
          display_name: "Test User"
        }}
    
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:errors][0][:message]).to eq("Email can't be blank")
    end

    it "returns an error when the password confirmation doesn't match" do
      post api_v1_users_path, params: {
        user: {
        email: "test1234@test.com",
        password: "password1",
        password_confirmation: "password",
        display_name: "Test User"
      }}

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:errors][0][:message]).to eq("Password confirmation doesn't match Password")
    end
  end
end