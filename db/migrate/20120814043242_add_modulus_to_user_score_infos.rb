class AddModulusToUserScoreInfos < ActiveRecord::Migration
  def change
    add_column :user_score_infos, :modulus, :float
  end
end
