set :output, 'log/cron.log'

every 1.day, :at => '0:00 am' do
  # (1..47).each do |i|
  #   s = "00#{i}"[-3, 3]
  #   runner "TvShow.get_from_rss(#{s})"
  # end
  runner "TvShow.get_from_rss"
end
