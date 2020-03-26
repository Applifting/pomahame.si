Rails.application.routes.draw do
  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :home, only: :index do
    post :test_post, on: :collection
    post :test_set, on: :collection
  end

  resource :volunteer, only: [] do
    post :register, on: :collection
    post :confirm, on: :collection
    post :resend, on: :collection
  end

  namespace :api do
    namespace :v1 do
      post '/geo/fulltext', to: 'geolocation#fulltext'
      post '/session/new', to: 'session#new'
      post '/session/create', to: 'session#create'
      namespace :volunteer do
        get 'profile'
        namespace :requests do
          get 'active', to: 'active'
        end
      end
    end
  end

  root 'home#index'
  get '/:slug', param: :slug, to: 'home#partner_signup', slug: /(?!.*?admin).*/

  namespace :docs do
    get '/partner-kit', to: redirect { 'https://drive.google.com/drive/folders/1w9_PVRbZ9VvE10zY0sR26f6SlmLq0xZn' }
  end
end
