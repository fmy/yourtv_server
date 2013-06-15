# -*- coding:utf-8 -*-
class TvShowsController < ApplicationController

  def index
    shows = TvShow.now(params[:area])
    render json: shows
  end

  private

end
