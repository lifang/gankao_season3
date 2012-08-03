class CreateTractates < ActiveRecord::Migration
  def change
    create_table :tractates do |t|
      t.integer :category_id
      t.integer :types
      t.integer :level
      t.string :tractate_url

      t.timestamps
    end
  end
end
