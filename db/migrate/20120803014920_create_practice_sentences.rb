class CreatePracticeSentences < ActiveRecord::Migration
  def change
    create_table :practice_sentences do |t|
      t.integer :category_id, :default =>2
      t.string :en_mean
      t.string :ch_mean
      t.integer :level
      t.string :enunciate_url
      t.string :error_mean
      t.text :title
      t.integer :types, :default => 0
      t.timestamps
    end
    add_index :practice_sentences,:category_id
    add_index :practice_sentences,:types
  end
end
