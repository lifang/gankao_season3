# encoding: utf-8
class Category < ActiveRecord::Base
  has_one :action_log
  has_many :category_manages
  has_many :users, :through=>:user_category_relations, :source => :user
  TYPE = {:CET4 => 2, :CET6 => 3, :GRADUATE => 4}
  FLAG = {2 => 'CET4', 3 => 'CET6', 4 => 'GRADUATE'}
end
