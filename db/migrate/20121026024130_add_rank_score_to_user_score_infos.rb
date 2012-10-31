class AddRankScoreToUserScoreInfos < ActiveRecord::Migration
    def change
    add_column :user_score_infos,  :rank_score, :integer
    add_column :user_score_infos,  :login_time,  :datetime
  end
end