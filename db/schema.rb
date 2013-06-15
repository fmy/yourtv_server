# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130615081837) do

  create_table "tv_shows", :force => true do |t|
    t.string   "title",       :null => false
    t.string   "description"
    t.string   "area",        :null => false
    t.string   "station",     :null => false
    t.datetime "start",       :null => false
    t.datetime "stop",        :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "tv_shows", ["station", "area", "start"], :name => "index_tv_shows_on_station_and_area_and_start", :unique => true

  create_table "users", :force => true do |t|
    t.string   "provider",                        :null => false
    t.string   "uid",                             :null => false
    t.string   "name",                            :null => false
    t.string   "image_url"
    t.string   "oauth_token"
    t.string   "oauth_token_secret"
    t.text     "word_hash"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "latest_tweet",       :limit => 8
  end

  add_index "users", ["provider", "uid"], :name => "index_users_on_provider_and_uid", :unique => true

end
