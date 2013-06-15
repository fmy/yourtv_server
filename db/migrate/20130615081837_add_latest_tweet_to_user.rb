class AddLatestTweetToUser < ActiveRecord::Migration
  def change
    add_column :users, :latest_tweet, :integer, :limit => 8
  end
end
