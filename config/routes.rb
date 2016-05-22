require 'resque/server'

Rails.application.routes.draw do

  get 'pages/index'
  root 'pages#index'

  mount Resque::Server.new, at: "/resque"

  devise_for :users, 
  :controllers => {
  	sessions: 'sessions', 
  	registrations: 'registrations', 
  	confirmations: 'confirmations'
  } 

  mount API => '/'
end