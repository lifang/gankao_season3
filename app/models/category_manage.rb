# encoding: utf-8
class CategoryManage < ActiveRecord::Base
  belongs_to :category
  belongs_to :user
end
