class RemoveColumnFromQuestionAnswers < ActiveRecord::Migration
  def up
    remove_column :question_answers,:quer_question_id
    add_column :question_answers,:user_question_id,:integer
    add_index :question_answers,:user_question_id
  end

  def down
  end
end
