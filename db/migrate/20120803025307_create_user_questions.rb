class CreateUserQuestions < ActiveRecord::Migration
  def change
    create_table :user_questions do |t|
      t.integer :user_id
      t.string :title
      t.string :description
      t.integer :category_id

      t.timestamps
    end
  end
end
