class AddImgUrlToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :img_url, :string
  end
end
