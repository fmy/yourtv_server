set :output, 'log/cron.log'
job_type :rbenv_bundle_runner, "export PATH=\"$HOME/.rbenv/bin:$PATH\"; eval \"$(rbenv init -)\"; cd :path && bundle exec script/rails runner -e 'development' ':task' :output"

every 1.day, at: "00:00 am" do
  (1..47).each do |i|
    s = "00#{i}"[-3, 3]
    rbenv_bundle_runner "TvShow.get_from_rss('#{s}', 5)"
  end
end

every 1.day, at: "01:00 am" do
  rbenv_bundle_runner "TvShow.sweep(1.days.ago)"
end
