# encoding: utf-8
class Examination < ActiveRecord::Base
  has_many :examination_paper_relations,:dependent => :destroy
  has_many :papers,:through=>:examination_paper_relations, :source => :paper
  belongs_to :user,:foreign_key=>"creater_id"
  has_many :exam_users,:dependent => :destroy
  has_many :examination_tag_relations,:dependent => :destroy
  has_many :tags,:through=>:examination_tag_relations, :source => :tag

  MAX_SCORE = {:CET4 => 550, :CET6 => 550, :GRADUATE => 75}
end
