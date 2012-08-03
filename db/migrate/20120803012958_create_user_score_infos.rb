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
  end
end
