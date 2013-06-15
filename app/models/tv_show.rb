# -*- coding:utf-8 -*-
class TvShow < ActiveRecord::Base
  attr_accessible :area, :description, :start, :station, :stop, :title

  def self.today(area)
    now = Time.now.beginning_of_day
    TvShow.where("area = ? and start <= ? and stop >= ?", area, now.since(1.days), now)
  end

  def self.now(area)
    now = Time.now
    TvShow.where("area = ? and start <= ? and stop >= ?", area, now.since(1.days), now)
  end

  # ------------ テレビ番組を取得 ------------
  #
  # area: 地域コード（下部参照）
  # date: 日付（YYYYmmdd）
  # hour: 時間（HH）
  # length: 取得時間の長さ（時間）
  #
  # config/schedule.rb で毎日0時に取得
  #
  def self.get_from_rss(area = "013", after = 0)
    require 'open-uri'

    time = Time.now.since(after.days).beginning_of_day
    day = time.to_date
    date = day.strftime "%Y%m%d"
    hour = "00"
    length = "24"

    url = "http://rey.rash.jp/junk/tv_rss.cgi?area=#{area}&sdate=#{date}&shour=#{hour}&lhour=#{length}"

    xml = Nokogiri::XML(open(url))
    xml.remove_namespaces!
    shows = xml.xpath("//RDF/item").map.with_index do |i, index|
      start_t, stop_t = i.xpath("time").text.split("～").map { |t| t.split(":")}
      start = Time.mktime(day.year, day.month, day.day, start_t[0], start_t[1])
      stop = Time.mktime(day.year, day.month, day.day, stop_t[0], stop_t[1])

      stop = stop.since(1.days) if start > stop
      if time.since(1.days) < stop and index < 10
        start = start.ago(1.days)
        stop = stop.ago(1.days)
      end

      show = TvShow.where(station: i.xpath("category").text, area: area, start: start).first_or_initialize
      show.description = i.xpath("description").text
      show.title = i.xpath("title").text.split(" [")[0]
      show.stop = stop
      show.save
      show
    end
  end

  # ------------ エリア一覧 ------------
  # 001 北海道 002 青森 003 岩手 004 宮城 005 秋田 006 山形 007 福島 008 茨城
  # 009 栃木 010 群馬 011 埼玉 012 千葉 013 東京 014 神奈川 015 新潟 016 富山
  # 017 石川 018 福井 019 山梨 020 長野 021 岐阜 022 静岡 023 愛知 024 三重
  # 025 滋賀 026 京都 027 大阪 028 兵庫 029 奈良 030 和歌山 031 鳥取 032 島根
  # 033 岡山 034 広島 035 山口 036 徳島 037 香川 038 愛媛 039 高知 040 福岡
  # 041 佐賀 042 長崎 043 熊本 044 大分 045 宮崎 046 鹿児島 047 沖縄

  def self.sweep(time = 1.days.ago)
    self.delete_all "stop < '#{time.to_s(:db)}'"
  end

end
