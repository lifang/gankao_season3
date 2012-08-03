class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.string   :title
      t.integer  :schedule_id
      t.string  :video_url
      t.timestamps
    end
    add_index :videos,:schedule_id
  end

  def self.down
    drop_table :videos
  end
end
