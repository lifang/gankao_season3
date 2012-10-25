# encoding: utf-8
class Tag < ActiveRecord::Base
  has_many :problem_tag_relations,:dependent=>:destroy
  has_many :problems,:through=>:problem_tag_relations,:foreign_key=>"problem_id"
  has_many :question_tag_relations,:dependent=>:destroy
  has_many :questions,:through=>:question_tag_relations,:foreign_key=>"question_id"

end
