# encoding: utf-8
class UserPlan < ActiveRecord::Base
  belongs_to :category
  belongs_to :user
  require 'rexml/document'
  include REXML
  
  CHAPTER_TYPE = {:WORD => "word", :SENTENCE => "sentence", :LINSTEN => "linsten", :READ => "read",
    :TRANSLATE => "translate", :DICTATION => "dictation", :WRITE => "write"}#单词、句子、听力、阅读、翻译、听写、写作
  CHAPTER = {:cha1 => "基础", :cha2 => "综合", :cha3 => "冲刺"}

  #返回复习计划的列表结构为：[[可开启的任务包]， [单词，句子，听力，时间段]， [阅读，翻译，听写，时间段]， [写作，时间段]]
  def get_plan_list
    file=File.open "#{Constant::PUBLIC_PATH}#{self.plan_url}"
    doc = Document.new(file)
    file.close
    chapter1 = doc.root.elements["plan"].elements["info"].elements["chapter1"]
    chapter2 = doc.root.elements["plan"].elements["info"].elements["chapter2"]
    chapter3 = doc.root.elements["plan"].elements["info"].elements["chapter3"]
     return {:current => doc.root.elements["plan"].elements["current"].text.to_i,
        :word => chapter1.attributes[CHAPTER_TYPE[:WORD]].to_i, :sentence => chapter1.attributes[CHAPTER_TYPE[:SENTENCE]].to_i,
        :linsten => chapter1.attributes[CHAPTER_TYPE[:LINSTEN]].to_i, :cha1_days => chapter1.attributes["days"].to_i,
        :read => chapter2.attributes[CHAPTER_TYPE[:READ]].to_i, :translate => chapter2.attributes[CHAPTER_TYPE[:TRANSLATE]].to_i,
        :dictation => chapter2.attributes[CHAPTER_TYPE[:DICTATION]].to_i, :cha2_days => chapter2.attributes["days"].to_i, 
        :write => chapter3.attributes[CHAPTER_TYPE[:WRITE]].to_i, :cha3_days => chapter3.attributes["days"].to_i}
  end
end
