# encoding: utf-8
class User < ActiveRecord::Base
  has_many :action_logs
  has_many :category_manages
  has_one :exam_user
  has_many :orders
  has_many :question_answers,:dependent=>:destroy
  has_many :categories, :through=>:user_category_relations,:source => :category
end
