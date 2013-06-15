class CreateTvShows < ActiveRecord::Migration
  def change
    create_table :tv_shows do |t|
      t.string :title, null: false
      t.string :description
      t.string :area, null: false
      t.string :station, null: false
      t.datetime :start, null: false
      t.datetime :stop, null: false

      t.timestamps
    end
    add_index :tv_shows, [:station, :area, :start], unique: true
  end
end
