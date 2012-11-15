class AddPTypesToExamUsers < ActiveRecord::Migration
  def change
    add_column :exam_users, :p_types, :boolean, :default => 0
  end
end
