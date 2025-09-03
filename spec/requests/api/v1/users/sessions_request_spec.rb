require 'rails_helper'

RSpec.describe "User Sessions", type: :request do
  before :each do
    @user = create(:user, email: 'test@example.com', password: 'Password123')
    @valid_credentials = {
      email: @user.email,
      password: 'Password123'
    }
  end

  describe "POST /api/v1/users/sign_in" do
    it "should successfully sign in with valid credentials" do
      post api_v1_user_session_path, params: @valid_credentials

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:ok)
      expect(json[:token]).not_to be_nil
      expect(json[:user][:data][:id]).to eq(@user.id.to_s)
      expect(json[:user][:data][:type]).to eq("user")
      expect(json[:user][:data][:attributes][:email]).to eq(@user.email)
      expect(json[:user][:data][:attributes][:display_name]).to eq(@user.display_name)
      expect(json[:user][:data][:attributes]).not_to have_key(:password)
      expect(json[:user][:data][:attributes]).not_to have_key(:created_at)
      expect(json[:user][:data][:attributes]).not_to have_key(:updated_at)
    end

    it "should return a valid JWT token that can be decoded" do
      post api_v1_user_session_path, params: @valid_credentials

      json = JSON.parse(response.body, symbolize_names: true)
      token = json[:token]

      expect(token).not_to be_nil
      
      payload = JWT.decode(token, Rails.application.credentials.secret_key_base, true, algorithm: 'HS256').first
      expect(payload['sub']).to eq(@user.id.to_s)
      expect(payload['jti']).to eq(@user.jti)
      expect(payload['aud']).to eq('user')
      expect(payload['exp']).to be > Time.current.to_i
    end

    it "should handle case-insensitive email login" do
      post api_v1_user_session_path, params: { email: @user.email.upcase, password: 'Password123' }

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:ok)
      expect(json[:token]).not_to be_nil
      expect(json[:user][:data][:attributes][:email]).to eq(@user.email.downcase)
    end

    it "should return error with invalid password" do
      post api_v1_user_session_path, params: { email: @user.email, password: 'wrongpassword' }

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:unauthorized)
      expect(json[:errors][0][:message]).to eq("Invalid credentials")
      expect(json[:token]).to be_nil
      expect(json[:user]).to be_nil
    end

    it "should return error with invalid email" do
      post api_v1_user_session_path, params: { email: 'nonexistent@example.com', password: 'Password123' }

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:unauthorized)
      expect(json[:errors][0][:message]).to eq("Invalid credentials")
      expect(json[:token]).to be_nil
      expect(json[:user]).to be_nil
    end

    it "should return error when email is missing" do
      post api_v1_user_session_path, params: { password: 'Password123' }

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:bad_request)
      expect(json[:errors][0][:message]).to eq("Email and password are required")
      expect(json[:token]).to be_nil
      expect(json[:user]).to be_nil
    end

    it "should return error when password is missing" do
      post api_v1_user_session_path, params: { email: @user.email }

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:bad_request)
      expect(json[:errors][0][:message]).to eq("Email and password are required")
      expect(json[:token]).to be_nil
      expect(json[:user]).to be_nil
    end

    it "should return error when both email and password are missing" do
      post api_v1_user_session_path, params: {}

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:bad_request)
      expect(json[:errors][0][:message]).to eq("Email and password are required")
      expect(json[:token]).to be_nil
      expect(json[:user]).to be_nil
    end

    it "should return error when email is blank" do
      post api_v1_user_session_path, params: { email: '', password: 'Password123' }

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:bad_request)
      expect(json[:errors][0][:message]).to eq("Email and password are required")
      expect(json[:token]).to be_nil
      expect(json[:user]).to be_nil
    end

    it "should return error when password is blank" do
      post api_v1_user_session_path, params: { email: @user.email, password: '' }

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:bad_request)
      expect(json[:errors][0][:message]).to eq("Email and password are required")
      expect(json[:token]).to be_nil
      expect(json[:user]).to be_nil
    end
  end

  describe "DELETE /api/v1/users/sign_out" do
    before :each do
      @token = @user.generate_jwt
    end

    it "should successfully sign out with valid token" do
      delete destroy_api_v1_user_session_path, headers: { 'Authorization' => "Bearer #{@token}" }

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:ok)
      expect(json[:message]).to eq("Logged out successfully")
    end

    # it "should invalidate the token after sign out" do
    #   delete destroy_api_v1_user_session_path, headers: { 'Authorization' => "Bearer #{@token}" }

    #   expect(response).to have_http_status(:ok)

    #   # Try to use the same token again - should fail
    #   delete destroy_api_v1_user_session_path, headers: { 'Authorization' => "Bearer #{@token}" }

    #   json = JSON.parse(response.body, symbolize_names: true)
    #   expect(response).to have_http_status(:unauthorized)
    #   expect(json[:error]).to eq("Invalid or expired token")
    # end

    it "should return error when token is missing" do
      delete destroy_api_v1_user_session_path

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:unauthorized)
      expect(json[:errors][0][:message]).to eq("Token is missing")
    end

    it "should return error with invalid token" do
      delete destroy_api_v1_user_session_path, headers: { 'Authorization' => "Bearer invalid_token" }

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:unauthorized)
      expect(json[:errors][0][:message]).to eq("Invalid or expired token")
    end

    # it "should return error with malformed authorization header" do
    #   delete destroy_api_v1_user_session_path, headers: { 'Authorization' => "InvalidFormat" }

    #   json = JSON.parse(response.body, symbolize_names: true)

    #   expect(response).to have_http_status(:unauthorized)
    #   expect(json[:error]).to eq("Token is missing")
    # end
  end
end