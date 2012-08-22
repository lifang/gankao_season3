class AddDetailToUsers < ActiveRecord::Migration
  def change
    add_column :skills, :remarks, :string
  end
end
