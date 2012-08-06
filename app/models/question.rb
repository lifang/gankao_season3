# encoding: utf-8
class Question < ActiveRecord::Base
  belongs_to :problem
  has_many :question_tag_relations,:dependent=>:destroy
  has_many :tags,:through=>:question_tag_relations,:source => :tag
  has_many :word_question_relations,:dependent=>:destroy
  has_many :words,:through=>:word_question_relations, :source => :word

end
