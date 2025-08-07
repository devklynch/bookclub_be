require 'rails_helper'

RSpec.describe "User Registration", type: :request do
  let(:valid_user_params) do
    {
      email: "test@test.com",
      password: "Password123",
      password_confirmation: "Password123",
      display_name: "Test User"
    }
  end

  before :each do
    @user = create(:user)
  end

  describe "POST /api/v1/users" do
    it "creates a new user with JWT token" do
      post api_v1_users_path, params: {
        user: valid_user_params
      }

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:created)
      expect(json[:user][:data][:id]).to eq(User.last.id.to_s)
      expect(json[:user][:data][:type]).to eq("user")
      expect(json[:user][:data][:attributes][:email]).to eq(valid_user_params[:email])
      expect(json[:user][:data][:attributes][:display_name]).to eq(valid_user_params[:display_name])
      expect(json[:token]).to be_present
      expect(json[:message]).to eq("User account created successfully")
    end

    it "returns an error when the email is already in use" do
      post api_v1_users_path, params: {  
        user: {
          email: @user.email,
          password: "Password123",
          password_confirmation: "Password123",
          display_name: "Test User"
        }}

      json = JSON.parse(response.body, symbolize_names: true)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:errors][0][:message]).to eq("Email has already been taken")
    end

    it "returns an error when required fields are missing" do
      post api_v1_users_path, params: {
        user: {
          email: "",
          password: "",
          password_confirmation: "",
          display_name: ""
        }}
    
      json = JSON.parse(response.body, symbolize_names: true)
      expect(response).to have_http_status(:bad_request)
      expect(json[:errors][0][:message]).to eq("Email, password, password confirmation, and display name are required")
    end

    it "returns an error when the password confirmation doesn't match" do
      post api_v1_users_path, params: {
        user: {
          email: "test1234@test.com",
          password: "Password123",
          password_confirmation: "Password456",
          display_name: "Test User"
        }}

      json = JSON.parse(response.body, symbolize_names: true)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:errors][0][:message]).to eq("Password confirmation doesn't match Password")
    end

    it "returns an error for invalid email format" do
      post api_v1_users_path, params: {
        user: {
          email: "invalid-email",
          password: "Password123",
          password_confirmation: "Password123",
          display_name: "Test User"
        }}

      json = JSON.parse(response.body, symbolize_names: true)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:errors][0][:message]).to eq("Email must be a valid email address")
    end

    it "returns an error for weak password" do
      post api_v1_users_path, params: {
        user: {
          email: "test@test.com",
          password: "weak",
          password_confirmation: "weak",
          display_name: "Test User"
        }}

      json = JSON.parse(response.body, symbolize_names: true)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:errors].any? { |error| error[:message].include?("must contain at least one") }).to be true
    end

    it "returns an error for display name that's too short" do
      post api_v1_users_path, params: {
        user: {
          email: "test@test.com",
          password: "Password123",
          password_confirmation: "Password123",
          display_name: "A"
        }}

      json = JSON.parse(response.body, symbolize_names: true)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:errors][0][:message]).to eq("Display name must be between 2 and 50 characters")
    end

    it "normalizes email to lowercase" do
      post api_v1_users_path, params: {
        user: {
          email: "TEST@TEST.COM",
          password: "Password123",
          password_confirmation: "Password123",
          display_name: "Test User"
        }}

      json = JSON.parse(response.body, symbolize_names: true)
      expect(response).to have_http_status(:created)
      expect(json[:user][:data][:attributes][:email]).to eq("test@test.com")
    end
  end
end