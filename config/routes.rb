Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      devise_for :users, controllers: {
        sessions: 'api/v1/users/sessions',
        registrations: 'api/v1/users/registrations'
      }

      resources :users do
        get "all_club_data", on: :member
        resources :events, only: [:show, :create] do
           resources :attendees, only: [:update]# users/user_id/events/event_id
        end
        resources :polls, only: [:show] do# users/user_id/polls/poll_id
          resources :options, only: [] do # users/user_id/polls/poll_id/
           resources :votes, only: [:create, :destroy] # users/user_id/polls/poll_id/options/option_id/votes
          end
        end
        resources :book_clubs, only: [:show] # users/user_id/book_clubs/book_club_id
      end
    end
  end

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check
end