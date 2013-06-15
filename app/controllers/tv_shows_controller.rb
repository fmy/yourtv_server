# -*- coding:utf-8 -*-
class TvShowsController < ApplicationController

  def index
    shows = TvShow.now(params[:area])
    render json: shows
  end

  def update
    result = TvShow.get_from_rss params[:area], params[:after].to_i

    response.headers["Content-Type"] = "text/html"
    render json: result
  end
  private

end
