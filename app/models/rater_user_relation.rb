#encoding: utf-8
class RaterUserRelation < ActiveRecord::Base
  belongs_to :exam_rater
  belongs_to :exam_user

end
