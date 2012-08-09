# encoding: utf-8
class UserScoreInfo < ActiveRecord::Base
  belongs_to :user
  belongs_to :category
end
