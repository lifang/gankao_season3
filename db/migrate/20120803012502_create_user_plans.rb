class CreateUserPlans < ActiveRecord::Migration
  def change
    create_table :user_plans do |t|
      t.integer :category_id
      t.integer :user_id
      t.date :started_at
      t.date :ended_at
      t.string :plan_url

      t.timestamps
    end
    add_index :user_plans,:user_id
    add_index :user_plans,:category_id
  end
end
