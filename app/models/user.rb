# -*- coding: utf-8 -*-
class User < ActiveRecord::Base
  attr_accessible :provider, :uid, :name, :image_url, :oauth_token, :oauth_token_secret

  def self.login(auth)
    logger.info auth
    where(auth.slice(:uid)).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.image_url = auth.info.image
      user.oauth_token = auth.credentials.token
      user.oauth_token_secret = auth.credentials.secret
      user.save!
    end
  end

  def analyze_tweets
    #認証方法
    Twitter.configure do |config|
     config.consumer_key = "US0M6rwza0mL7ODztOwEA"
     config.consumer_secret = "uvBwZzSAo8oWom5I9RgN8T6JUhCxLiNZRhi0qFDA"
     config.oauth_token = oauth_token
     config.oauth_token_secret = oauth_token_secret
    end

    tagger = Igo::Tagger.new("#{Rails.root}/extras/ipadic")
    rt = []

    #最近retweetされた自分のtweetを取得して各tweetをparseしてばらばらにする
    Twitter.user_timeline(:count=>200).each do |t|
            #毎ツイートに付与される定型文の部分をカット
      t.text.gsub!(/→.*http:.*/,'')
      t.text.gsub!(/@.*/,'')
      t.text.gsub!(/via.*/,'')
      t.text.gsub!(/RT/,'')
      t.text.gsub!(/http:.*/,'')
      t.text.gsub!(/&gt;&lt;/,'')
      tagger.parse(t.text.encode('utf-8')).each do |m|
        if m.feature =~ /名詞.*/
          rt << m.surface
        end
      end
    end

    #parseしたtweetの重複している言葉の個数を数える
    ranks = []
    rt.uniq.map do |t|
      next if t.length <= 1
      next if rt.grep(t).count< 3#出現回数が3未満のwordを削除
      ranks << "#{sprintf('%02d',rt.grep(t).count)}=>#{t}"
    end

    #parseしたtweetが入っている配列を降順にならべかえて出力
    #降順でソート。sprintfで0詰めしてるからなんとかなる
    ranks.sort{|a,b| b <=> a}
  end

end
