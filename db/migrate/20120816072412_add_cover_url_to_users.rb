class AddCoverUrlToUsers < ActiveRecord::Migration
  def change
    add_column :users, :cover_url, :string
  end
end
