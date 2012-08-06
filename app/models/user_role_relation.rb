# encoding: utf-8
class UserRoleRelation < ActiveRecord::Base
  belongs_to :role
  belongs_to :user
end
