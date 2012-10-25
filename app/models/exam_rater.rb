#encoding: utf-8
class ExamRater < ActiveRecord::Base
 has_many :rater_user_relations,:dependent=>:destroy
end
