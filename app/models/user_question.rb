# encoding: utf-8
class UserQuestion < ActiveRecord::Base
  belongs_to :category
  belongs_to :user
end
