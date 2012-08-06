# encoding: utf-8
class UserQuestion < ActiveRecord::Base
  belongs_to :user
  has_many :question_answers,:dependent=>:destroy

  default_scope order: 'user_questions.created_at DESC'
end
