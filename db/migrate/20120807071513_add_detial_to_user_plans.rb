class AddDetialToUserPlans < ActiveRecord::Migration
  def change
    remove_column :user_plans, :started_at
    remove_column :user_plans, :ended_at
    add_column :user_plans, :days, :integer
  end
end
