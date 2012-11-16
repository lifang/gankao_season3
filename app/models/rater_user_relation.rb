#encoding: utf-8
class RaterUserRelation < ActiveRecord::Base
  belongs_to :exam_rater
  belongs_to :exam_user

  IS_MARKED = {:YES => 1, :NO => 0} #1 已批阅  0  未批阅
end
