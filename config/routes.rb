Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      devise_for :users, controllers: {
        sessions: 'api/v1/users/sessions',
        registrations: 'api/v1/users/registrations'
      }

      resources :users do
        resources :events, only: [:show] # users/user_id/events/event_id
        resources :polls, only: [:show] # users/user_id/polls/poll_id
        resources :book_clubs, only: [:show] # users/user_id/book_clubs/book_club_id
      end
    end
  end

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check
end