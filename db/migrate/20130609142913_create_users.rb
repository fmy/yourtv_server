class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :provider, null: false
      t.string :uid, null: false
      t.string :name, null: false
      t.string :image_url
      t.string :oauth_token
      t.string :oauth_token_secret
      t.text :word_hash

      t.timestamps
    end
    add_index :users, [:provider, :uid], unique: true
  end
end
