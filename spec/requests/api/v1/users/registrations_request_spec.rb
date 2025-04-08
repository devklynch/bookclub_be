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
  end
end