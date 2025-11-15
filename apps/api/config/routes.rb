Rails.application.routes.draw do
  # Health check endpoint (no versioning needed)
  get "up" => "rails/health#show", as: :rails_health_check

  # API v1 routes
  namespace :api do
    namespace :v1 do
      # Health check endpoint
      get 'health', to: 'health#show'

      # Authentication routes
      namespace :auth do
        post :register
        post :login
        post :refresh
        delete :logout
        post :verify_email
        post :forgot_password
        post :reset_password
      end

      # User routes
      resources :users, only: [:index, :show, :update, :destroy] do
        member do
          get :profile
          get :videos
          get :posts
          get :comments
        end
      end

      # Video routes
      resources :videos do
        member do
          post :publish
          post :archive
        end

        # Nested comments for videos
        resources :comments, only: [:index, :create]

        # Reactions on videos
        resources :reactions, only: [:index, :create, :destroy]
      end

      # Post routes
      resources :posts do
        member do
          post :publish
          post :archive
        end

        # Nested comments for posts
        resources :comments, only: [:index, :create]

        # Reactions on posts
        resources :reactions, only: [:index, :create, :destroy]
      end

      # Comment routes (for updates and nested replies)
      resources :comments, only: [:index, :show, :update, :destroy] do
        # Nested replies
        post :replies, on: :member

        # Reactions on comments
        resources :reactions, only: [:index, :create, :destroy]
      end

      # Reaction routes
      resources :reactions, only: [:index, :destroy]

      # Report routes
      resources :reports, only: [:index, :show, :create, :update] do
        member do
          post :review
          post :resolve
          post :reject
        end
      end

      # Admin routes
      namespace :admin do
        resources :users, only: [:index, :show, :update, :destroy] do
          member do
            post :suspend
            post :activate
          end
        end

        resources :reports, only: [:index, :show, :update]
        resources :audit_logs, only: [:index, :show]

        # Statistics and analytics
        get 'statistics/overview'
        get 'statistics/users'
        get 'statistics/content'
      end
    end

    # API v2 routes (future proofing)
    # namespace :v2 do
    #   # Future API version
    # end
  end

  # Swagger/OpenAPI documentation
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  # Root path
  root to: proc { [200, {}, ['Rails Next.js Commentable API - See /api-docs for documentation']] }
end
