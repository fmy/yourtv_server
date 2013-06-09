YourtvServer::Application.routes.draw do

  # OAuth
  match "/auth/:provider/callback" => "sessions#create"
  match "/logout" => "sessions#destroy"

end
