# encoding: utf-8
class Examination < ActiveRecord::Base
  has_many :examination_paper_relations,:dependent => :destroy
  has_many :papers,:through=>:examination_paper_relations, :source => :paper
  belongs_to :user,:foreign_key=>"creater_id"
  has_many :exam_users,:dependent => :destroy
  has_many :examination_tag_relations,:dependent => :destroy
  has_many :tags,:through=>:examination_tag_relations, :source => :tag

  STATUS = {:EXAMING => 0, :LOCK => 1, :GOING => 2,  :CLOSED => 3 } #考试的状态：0 考试中 1 未开始 2 进行中 3 已结束
  IS_PUBLISHED = {:NEVER => 0, :ALREADY => 1} #是否发布  0 没有 1 已经发布
  IS_FREE = {:YES => 1, :NO => 0} #是否免费 1是 0否

  TYPES = {:SIMULATION => 0, :OLD_EXAM => 1, :PRACTICE => 2, :SPECIAL => 3}
  #考试的类型： 0 模拟考试  1 真题练习  2 综合训练  3 专项练习
  TYPE_NAMES = {0 => "模拟考试", 1 => "真题练习", 2 => "综合训练", 3 => "专项练习"}
  
end
