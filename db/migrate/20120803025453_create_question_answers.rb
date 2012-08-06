class CreateQuestionAnswers < ActiveRecord::Migration
  def change
    create_table :question_answers do |t|
      t.integer :user_id
      t.integer :quer_question_id
      t.string :answer

      t.timestamps
    end
    add_index :question_answers,:user_id
    add_index :question_answers,:quer_question_id
  end
end
