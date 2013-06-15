YourtvServer::Application.routes.draw do

  # OAuth
  get "login", to: "users#new"
  match "/auth/:provider/callback", to: "sessions#create"
  match "/logout", to: "sessions#destroy"

  # tv
  get "tv_shows/:area", to: "tv_shows#index"

  # user
  get "users/:id", to: "users#show"
  get "users/:id/first/:area", to: "users#first"
  get "users/:id/tv_shows/:area", to: "users#tv_shows"
  get "users/:id/analyze", to: "users#analyze"
  get "users/:id/words", to: "users#words"

end
