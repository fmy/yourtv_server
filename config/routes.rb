YourtvServer::Application.routes.draw do

  # OAuth
  match "/auth/:provider/callback", to: "sessions#create"
  match "/logout", to: "sessions#destroy"

  # tv
  get "tv/get", to: "tv_shows#get"

  # user
  get "users/:id", to: "users#show"
  get "users/:id/tweets", to: "users#tweets"

end
