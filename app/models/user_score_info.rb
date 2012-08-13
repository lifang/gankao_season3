# encoding: utf-8
class UserScoreInfo < ActiveRecord::Base
  belongs_to :user
  belongs_to :category


  #取到默认开始的词库、句子跟听力
  def get_start_level
    all_start_level =  self.all_start_level.split(",")
    words = Word.find(:select => "id", :conditions => ["category_id = ? and level = ?",
        self.category_id, all_start_level[0]])
    word_list = words.collect { |w| w.id }
    practice_sentences = PracticeSentence.find(:select => "id",
      :conditions => ["category_id = ? and types = ? and level = ?",
        self.category_id, PracticeSentence::TYPES[:SENTENCE], all_start_level[1]])
    sentence_list = practice_sentences.collect { |s| s.id }
    listens = PracticeSentence.find(:select => "id",
      :conditions => ["category_id = ? and types = ? and level = ?",
        self.category_id, PracticeSentence::TYPES[:LINSTEN], all_start_level[2]])
    listen_list = listens.collect { |l| l.id }
    return {:word => word_list, :practice_sentences => sentence_list, :listens => listen_list, :levels => all_start_level}
  end
end
