class CreateUserScoreInfos < ActiveRecord::Migration
  def change
    create_table :user_score_infos do |t|
      t.integer :category_id
      t.integer :user_id
      t.integer :start_score
      t.integer :target_score
      t.string :all_start_level

      t.timestamps
    end
    add_index :user_score_infos,:category_id
    add_index :user_score_infos,:user_id
  end
end
