class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :authorized?

  private

  def authorized?
    true if session[:oauth_token]
  end

end
