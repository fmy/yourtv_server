class TvController < ApplicationController

  def get
    shows = get_tv_rss(params[:area], params[:date], params[:hour], params[:length])
    render json: shows
  end

  private

  # ------------ テレビ番組を取得 ------------
  #
  # area: 地域コード（下部参照）
  # date: 日付（YYYYmmdd）
  # hour: 時間（HH）
  # length: 取得時間の長さ（時間）
  #
  def get_tv_rss(area, date, hour, length)
    require 'open-uri'

    area ||= "013"
    start = Time.now
    date ||= start.strftime("%Y%m%d")
    hour ||= start.strftime("%H")
    length ||= "24"

    url = "http://rey.rash.jp/junk/tv_rss.cgi?area=#{area}&sdate=#{date}&shour=#{hour}&lhour=#{length}"

    xml = Nokogiri::XML(open(url))
    xml.remove_namespaces!
    shows = xml.xpath("//RDF/item").map do |i|
      {
        title: i.xpath("title").text.split(" [")[0],
        station: i.xpath("category").text,
        start: i.xpath("time").text,
        description: i.xpath("description").text
      }
    end
  end

  # ------------ エリア一覧 ------------
  # 001 北海道 002 青森 003 岩手 004 宮城 005 秋田 006 山形 007 福島 008 茨城
  # 009 栃木 010 群馬 011 埼玉 012 千葉 013 東京 014 神奈川 015 新潟 016 富山
  # 017 石川 018 福井 019 山梨 020 長野 021 岐阜 022 静岡 023 愛知 024 三重
  # 025 滋賀 026 京都 027 大阪 028 兵庫 029 奈良 030 和歌山 031 鳥取 032 島根
  # 033 岡山 034 広島 035 山口 036 徳島 037 香川 038 愛媛 039 高知 040 福岡
  # 041 佐賀 042 長崎 043 熊本 044 大分 045 宮崎 046 鹿児島 047 沖縄

end
