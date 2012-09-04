class AddImgUrlToUsers < ActiveRecord::Migration
  def change
    add_column :users, :img_url, :string
  end
end
