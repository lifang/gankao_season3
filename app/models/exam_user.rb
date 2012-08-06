# encoding: utf-8
class ExamUser < ActiveRecord::Base
  belongs_to :examination
  belongs_to :user
  belongs_to :paper
  has_many :rater_user_relations,:dependent=>:destroy
end
