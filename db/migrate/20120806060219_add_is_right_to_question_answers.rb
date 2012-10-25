class AddIsRightToQuestionAnswers < ActiveRecord::Migration
  def change
    add_column :question_answers, :is_right, :boolean, :default => 0
    add_index :question_answers, :is_right
  end
end
