class CreateSkills < ActiveRecord::Migration
  def change
    create_table :skills do |t|
      t.integer :types
      t.string  :skill_title
      t.string  :skill_url
      t.integer :category_id
      t.timestamps
    end
    add_index :skills,:category_id
  end
end
