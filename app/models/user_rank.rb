# encoding: utf-8
class UserRank < ActiveRecord::Base
  belongs_to :category
  belongs_to :user
end
