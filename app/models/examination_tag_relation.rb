# encoding: utf-8
class ExaminationTagRelation < ActiveRecord::Base
  belongs_to :examination
  belongs_to :tag
end
