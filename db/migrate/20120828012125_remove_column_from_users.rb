class RemoveColumnFromUsers < ActiveRecord::Migration
  def up
    remove_column :users,:signin_days
    add_column :users, :signin_days, :string , :default=>"CET4=>0,CET6=>0,GRADUATE=>0"
  end

  def down
  end
end
