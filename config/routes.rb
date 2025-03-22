Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      namespace :app do
        post "auth/register", to: "auth#register"
        post "auth/login", to: "auth#login"

        resources :users, only: [ :index, :show, :update, :destroy ]
      end
    end
  end
end
