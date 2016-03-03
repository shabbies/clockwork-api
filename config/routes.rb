Rails.application.routes.draw do

  get 'pages/index'
  root 'pages#index'

  devise_for :users, 
  :controllers => {
  	sessions: 'sessions', 
  	registrations: 'registrations', 
  	confirmations: 'confirmations'
  } 

  mount API => '/'
end