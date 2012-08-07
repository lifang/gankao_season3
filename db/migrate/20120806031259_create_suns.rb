class CreateSuns < ActiveRecord::Migration
  def change
    create_table :suns do |t|
      t.integer :category_id
      t.integer :types
      t.integer :user_id
      t.integer :num
      t.timestamps
    end
    add_index :suns,:category_id
    add_index :suns,:user_id
  end
end
