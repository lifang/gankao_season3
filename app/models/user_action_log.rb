# encoding: utf-8
class UserActionLog < ActiveRecord::Base
  belongs_to :user
end
