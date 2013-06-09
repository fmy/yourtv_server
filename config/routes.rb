YourtvServer::Application.routes.draw do

  # OAuth
  match "/auth/:provider/callback" => "sessions#create"
  match "/logout" => "sessions#destroy"

  # tv
  get "tv/get"

end
