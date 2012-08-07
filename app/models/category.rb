# encoding: utf-8
class Category < ActiveRecord::Base
  has_one :action_log
  has_many :category_manages
  has_many :users, :through=>:user_category_relations, :source => :user

end
