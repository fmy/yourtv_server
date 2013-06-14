# -*- coding:utf-8 -*-
class TvShowsController < ApplicationController

  def get
    shows = TvShow.today
    # shows = get_tv_sonet()
    render json: shows
  end

  private


end
