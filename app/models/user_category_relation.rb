# encoding: utf-8
class UserCategoryRelation < ActiveRecord::Base
  belongs_to :user
  belongs_to :category
end
