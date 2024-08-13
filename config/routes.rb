Rails.application.routes.draw do
   root "users#show"
   get "/login", to: "sessions#new"
   post "/login", to: "sessions#create"
   resources :books do
     resources :episodes
   end
   match "*unmatched", to: "errors#render404", via: :all
 end
