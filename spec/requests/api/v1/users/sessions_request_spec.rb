require 'rails_helper'

RSpec.describe "User Sessions", type: :request do
  let(:user) { create(:user) }
  let(:valid_credentials) do
    {
      email: user.email,
      password: user.password
    }
  end

  describe "POST /api/v1/users/sign_in" do
    it "returns a JWT token" do
      post api_v1_user_session_path, params: valid_credentials

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:ok)
      expect(json[:token]).not_to be_nil
    end

    it "returns an error message" do
      post api_v1_user_session_path, params: { email: user.email, password: 'wrongpassword' }

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:unauthorized)
      expect(json[:error]).to eq("Invalid credentials")
    end

    it "returns an error when email is missing" do
      post api_v1_user_session_path, params: { password: user.password }

      json = JSON.parse(response.body, symbolize_names: true) 
      
      expect(response).to have_http_status(:bad_request)
      expect(json[:error]).to eq("Email and password are required")
    end
  end
end