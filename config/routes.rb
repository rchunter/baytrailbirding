Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'application#index'
  post '/bird', to: 'sightings#nearby_birds'
  get '/bird', to: 'sightings#update_database'
end
