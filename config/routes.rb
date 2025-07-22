Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      devise_for :users, controllers: {
        sessions: 'api/v1/users/sessions',
        registrations: 'api/v1/users/registrations'
      }

      resources :users do
        get "all_club_data", on: :member

        # Only keep user-book_club routes if needed for show
        resources :book_clubs, only: [:show]

        resources :polls, only: [:show, :create] do
          resources :options, only: [:create] do
            resources :votes, only: [:create, :destroy]
          end
        end
      end

      # Routes for creating and showing events under book clubs
      resources :book_clubs, only: [] do
        resources :events, only: [:create, :show] do
          resources :attendees, only: [:update]
        end

          resources :polls, only: [:create, :show]
      end
    end
  end


  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check
end