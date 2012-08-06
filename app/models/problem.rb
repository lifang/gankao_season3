# encoding: utf-8
class Problem < ActiveRecord::Base
  has_one:problem_tag
  belongs_to:category
  has_many:problem_tag_relations,:dependent=>:destroy
  has_many :tags,:through=>:problem_tag_relations,:foreign_key=>"tag_id"
  has_many:questions,:dependent=>:destroy


end



