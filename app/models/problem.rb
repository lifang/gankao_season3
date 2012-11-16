# encoding: utf-8
class Problem < ActiveRecord::Base
  has_one:problem_tag
  belongs_to:category
  has_many:problem_tag_relations,:dependent=>:destroy
  has_many :tags,:through=>:problem_tag_relations,:foreign_key=>"tag_id"
  has_many:questions,:dependent=>:destroy

 #小题类型 题面外：0  题面内：1
  QUESTION_TYPE = {:OUTER=>0,:INNER=>1}
end



