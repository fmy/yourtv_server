YourtvServer::Application.routes.draw do

  # OAuth
  get "login", to: "users#new"
  match "/auth/:provider/callback", to: "sessions#create"
  match "/logout", to: "sessions#destroy"

  # tv
  get "tv_shows/:area", to: "tv_shows#index"
  get "tv_shows/:area/update(/:after)", to: "tv_shows#update"

  # user
  get "users/:id", to: "users#show"
  get "users/:id/first/:area", to: "users#first"
  get "users/:id/tv_shows/:area", to: "users#tv_shows"
  get "users/:id/analyze", to: "users#analyze"
  get "users/:id/words(/:min)", to: "users#words"
  get "users/:id/reset_words", to: "users#reset_words"

end
