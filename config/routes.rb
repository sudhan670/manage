Rails.application.routes.draw do
  devise_for :users
  
  resources :rooms do
    resources :bookings, only: [:new, :create]
  end
  
  resources :bookings, only: [:index, :show, :destroy]
  resources :meeting_participants, only: [:update]
  
  namespace :admin do
    get "users/index"
    get "users/edit"
    get "users/update"
    get 'dashboard', to: 'admin#dashboard'
    resources :users, only: [:index, :edit, :update]
  end
  resources :bookings do
    collection do
      get :my_invitations
    end
    member do
      post :invite
      post :respond_to_invitation
    end
  end
  
  root to: 'rooms#index'
end