class CreateTractates < ActiveRecord::Migration
  def change
    create_table :tractates do |t|
      t.integer :category_id
      t.integer :types
      t.integer :level
      t.string :tractate_url

      t.timestamps
    end
    add_index :tractates,:category_id
    add_index :tractates,:types
    add_index :tractates,:level
  end
end
