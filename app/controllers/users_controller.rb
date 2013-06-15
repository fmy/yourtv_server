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
    words = User.find(params[:id]).words(params[:min].to_i)

    response.headers["Content-Type"] = "text/html"
    render json: words.to_json
  end

  def analyze
    user = User.find(params[:id])
    words = user.analyze_tweets

    response.headers["Content-Type"] = "text/html"
    render json: words.to_json
  end

  def tv_shows
    user = User.find(params[:id])
    shows = user.recommends(params[:area])

    response.headers["Content-Type"] = "text/html"
    render json: shows
  end

  def reset_words
    user = User.find(params[:id])
    user.word_hash = nil
    user.latest_tweet = nil
    user.save
    user.first_analyze

    response.headers["Content-Type"] = "text/html"
    render json: user
  end
end
