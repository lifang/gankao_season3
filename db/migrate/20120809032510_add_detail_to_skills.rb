class AddDetailToSkills < ActiveRecord::Migration
  change_table(:skills) do |t|
    #    t.remove :company_id
    t.integer :readed_num,:like_num, :null => false, :default => 0
    t.integer :user_id, :null => false
    t.string  :simplify_con
  end
end
