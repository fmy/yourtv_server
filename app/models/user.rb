# -*- coding: utf-8 -*-
class User < ActiveRecord::Base
  attr_accessible :provider, :uid, :name, :image_url, :oauth_token, :oauth_token_secret, :word_hash, :latest_tweet

  def self.login(auth)
    user = where(auth.slice(:uid)).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.image_url = auth.info.image
      user.oauth_token = auth.credentials.token
      user.oauth_token_secret = auth.credentials.secret
      user.save!
    end
    user.analyze_tweets
    user
  end

  def recommends(area = "013")
    unless word_hash
      analyze_tweets
      return false
    end
    hash = Hash[word_hash.split("\t").map{|f| f.split(":", 2)}]
    words = []
    hash.each { |word, count| words << word if count.to_i >= 2 }
    now = Time.now
    shows = []
    words.each do |word|
      shows = shows | TvShow.where("area = ? and start <= ? and stop >= ? and ( title like ? or description like ? )", area, now.since(1.days), now, "%#{word}%", "%#{word}%")
    end
    shows
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
    options = {
      count: 200,
      trim_user: true
    }

    Twitter.user_timeline(options).each_with_index do |t|
      break if t.id == self.latest_tweet
      #毎ツイートに付与される定型文の部分をカット
      t.text.gsub!(/→.*http:.*/,'')
      t.text.gsub!(/@.*/,'')
      t.text.gsub!(/via.*/,'')
      t.text.gsub!(/RT/,'')
      t.text.gsub!(/\.\.\./,'')
      t.text.gsub!(/http:.*/,'')
      t.text.gsub!(/https:.*/,'')
      t.text.gsub!(/&gt;&lt;/,'')
      t.text.gsub!(/www/,'')
      t.text.gsub!(/・/,'')
      t.text.gsub!(/,/,'')
      tagger.parse(t.text.encode('utf-8')).each do |m|
        if m.feature =~ /名詞.*/
          rt << m.surface
        end
      end
    end

    self.latest_tweet = Twitter.user_timeline(options).first.id

    hash = self.word_hash ? Hash[self.word_hash.split("\t").map{|f| f.split(":", 2)}] : {}
    new_hash = {}
    # ranks = []
    if hash.any?
      hash.each do |w, c|
        new_hash[w] = hash[w] unless rt.uniq.include?(w)
      end
      array = hash.map { |w, c| w }
      rt.uniq.each do |t|
        next if t.length <= 1
        if array.include?(t)
          new_hash[t] = (hash[t].to_i + rt.grep(t).count).to_s
        else
          new_hash[t] = rt.grep(t).count.to_s
        end
      end
    else
      rt.uniq.each do |t|
        new_hash[t] = rt.grep(t).count.to_s
      end
    end

      # next if rt.grep(t).count< 3#出現回数が3未満のwordを削除
      # ranks << "#{sprintf('%02d',rt.grep(t).count)}=>#{t}"
      # ranks[t] = rt.grep(t).count

    #parseしたtweetが入っている配列を降順にならべかえて出力
    # sort (-) は降順
    # hash_ranks = ranks.sort_by{ |key, value| -value }
    self.word_hash = new_hash.map { |word, count| "#{word}:#{count}" }.join("\t")
    self.save!
    new_hash
  end

end
