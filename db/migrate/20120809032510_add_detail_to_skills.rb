class AddDetailToSkills < ActiveRecord::Migration
  def change
    add_column :skills, :readed_num, :integer, :default => 0
    add_column :skills, :like_num, :integer, :default => 0
    add_column :skills, :user_id, :integer
    add_column :skills, :simplify_con, :string
    add_index :skills, :readed_num
  end
end
