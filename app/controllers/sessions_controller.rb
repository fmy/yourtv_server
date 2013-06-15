class SessionsController < ApplicationController

  def create
    user = User.login(env["omniauth.auth"])
    session[:user_id] = user.id

    response.headers["Content-Type"] = "text/html"
    render json: user
  end

  def destroy
    session[:user_id] = nil
    render json: "logout"
  end

end
