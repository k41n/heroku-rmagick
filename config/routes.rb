Rails.application.routes.draw do
  root 'merges#new'

  resources :merges, only: [:create, :new]
end
