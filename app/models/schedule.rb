# encoding: utf-8
class Schedule < ActiveRecord::Base
  has_many :videos
end
