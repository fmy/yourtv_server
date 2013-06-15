# -*- coding:utf-8 -*-
class TvShowsController < ApplicationController

  def index
    shows = TvShow.today(params[:area])
    # shows = get_tv_sonet()
    render json: shows
  end

  private

end
