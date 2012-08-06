# encoding: utf-8
class ProblemTagRelation < ActiveRecord::Base
  belongs_to :tag
  belongs_to :problem
end
