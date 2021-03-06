class CreateTweets < ActiveRecord::Migration[6.0]
  def change
    create_table :tweets do |t|
      t.references :episode
      t.bigint :tweet_id, null: false
      t.bigint :progress_time_msec, null: false
      t.bigint :serial_number, null: false
      t.string :name, null: false
      t.string :screen_name, null: false
      t.string :profile_image_url, null: false
      t.text :text, null: false
      t.string :image_url1
      t.string :image_url2
      t.string :image_url3
      t.string :image_url4
      t.datetime :tweeted_at, null: false
      t.timestamps
    end
    add_index :tweets, :tweet_id, unique: true
    add_index :tweets, :tweeted_at
  end
end
