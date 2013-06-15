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
    hash = parse(word_hash)
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
    prepare_analyze
    tweets = Twitter.user_timeline(count: 200, trim_user: true)
    words = analyze(tweets)
    self.latest_tweet = tweets.first.id

    new_hash = merge_hash(words)
    self.word_hash = serialize(new_hash)
    self.save!
    new_hash
  end

  def first_analyze # 未実装
    prepare_analyze
    tweets = (1..5).flat_map do |page|
      Twitter.user_timeline(count: 200, page: page, trim_user: true)
    end
  end

  def prepare_analyze
    #認証方法
    Twitter.configure do |config|
     config.consumer_key = "US0M6rwza0mL7ODztOwEA"
     config.consumer_secret = "uvBwZzSAo8oWom5I9RgN8T6JUhCxLiNZRhi0qFDA"
     config.oauth_token = oauth_token
     config.oauth_token_secret = oauth_token_secret
    end
  end

  def analyze(tweets)
    words = []
    tagger = Igo::Tagger.new("#{Rails.root}/extras/ipadic")
    tweets.each do |t|
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
      t.text.gsub!(/[0-9]+/,'')
      tagger.parse(t.text.encode('utf-8')).each do |m|
        if m.feature =~ /名詞.*/
          words << m.surface
        end
      end
    end
    words
  end

  def merge_hash(words)
    hash = word_hash ? parse(word_hash) : {}
    new_hash = {}
    if hash.any?
      hash.each do |w, c|
        new_hash[w] = hash[w] unless words.uniq.include?(w)
      end
      array = hash.map { |w, c| w }
      words.uniq.each do |t|
        next if t.length <= 1
        if array.include?(t)
          new_hash[t] = (hash[t].to_i + words.grep(t).count).to_s
        else
          new_hash[t] = words.grep(t).count.to_s
        end
      end
    else
      words.uniq.each do |t|
        next if t.length <= 1
        new_hash[t] = words.grep(t).count.to_s
      end
    end
    new_hash
  end

  def parse(string)
    Hash[string.split("\t").map{|f| f.split(":", 2)}]
  end

  def serialize(hash)
    hash.map { |word, count| "#{word}:#{count}" }.join("\t")
  end

end
