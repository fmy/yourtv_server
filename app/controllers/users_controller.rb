class UsersController < ApplicationController

  def show
    user = User.find(params[:id])
    render json: user.to_json(only: [:id, :name, :image_url])
  end

  def tweets
    user = User.find(params[:id])
    tweets = user.analyze_tweets
    render json: tweets.to_json
  end

end
