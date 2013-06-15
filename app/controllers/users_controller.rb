class UsersController < ApplicationController

  def new
  end

  def show
    user = User.find(params[:id])
    render json: user.to_json(only: [:id, :name, :image_url])
  end

  def first
    user = User.find(params[:id])
    user.first_analyze
    shows = user.recommends(params[:area])

    response.headers["Content-Type"] = "text/html"
    render json: shows
  end

  def words
    words = User.find(params[:id]).words
    render json: words.to_json
  end

  def analyze
    user = User.find(params[:id])
    words = user.analyze_tweets
    render json: words.to_json
  end

  def tv_shows
    user = User.find(params[:id])
    shows = user.recommends(params[:area])

    response.headers["Content-Type"] = "text/html"
    render json: shows
  end

end
