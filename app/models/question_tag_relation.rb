# encoding: utf-8
class QuestionTagRelation < ActiveRecord::Base
  belongs_to :tag
  belongs_to :question
end
