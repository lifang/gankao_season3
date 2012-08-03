class RemoveColumnFromQuestionAnswers < ActiveRecord::Migration
  def up
    remove_column :quer_question_id
    add_column :question_answers,:user_question_id,:integer
  end

  def down
  end
end
