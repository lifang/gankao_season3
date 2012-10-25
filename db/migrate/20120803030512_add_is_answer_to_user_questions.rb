class AddIsAnswerToUserQuestions < ActiveRecord::Migration
  def change
    add_column :user_questions, :is_answer, :boolean, :default => 0
    add_index :user_questions,:is_answer
  end
end
