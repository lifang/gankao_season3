# encoding: utf-8
class UserQuestion < ActiveRecord::Base
  belongs_to :user
  has_many :question_answers,:dependent=>:destroy
  IS_ANSWERED = {:YES => 1, :NO => 0} #1 回答 0 未回答

  default_scope order: 'user_questions.created_at DESC'

 
end
