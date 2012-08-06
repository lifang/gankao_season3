# encoding: utf-8
class QuestionAnswer < ActiveRecord::Base
  belongs_to :user
  belongs_to :question, :foreign_key=>"user_questioin_id"
end
