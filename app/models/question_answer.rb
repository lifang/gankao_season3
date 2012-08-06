# encoding: utf-8
class QuestionAnswer < ActiveRecord::Base
  belongs_to :user
  belongs_to :user_question, :foreign_key=>"user_questioin_id"

  default_scope order: 'question_answers.created_at DESC'
end
