class AddDetailToUsers < ActiveRecord::Migration
  def change
    add_column :users, :remarks, :string
  end
end
