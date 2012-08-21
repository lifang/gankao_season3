class AddStatusToSkills < ActiveRecord::Migration
  def change
    add_column :skills, :status, :boolean, :default => 0
  end
end
