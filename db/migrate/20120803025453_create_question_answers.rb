class CreateQuestionAnswers < ActiveRecord::Migration
  def change
    create_table :question_answers do |t|
      t.integer :user_id
      t.integer :quer_question_id
      t.string :answer

      t.timestamps
    end
  end
end
