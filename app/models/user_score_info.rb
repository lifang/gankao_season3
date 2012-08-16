# encoding: utf-8
class UserScoreInfo < ActiveRecord::Base
  belongs_to :user
  belongs_to :category


  #取到默认开始的词库、句子跟听力
  def get_start_level
    all_start_level =  self.all_start_level.split(",")
    words = Word.find(:all, :select => "id", :conditions => ["category_id = ? and level = ?",
        self.category_id, all_start_level[0]])
    word_list = words.collect { |w| w.id }
    practice_sentences = PracticeSentence.find(:all, :select => "id",
      :conditions => ["category_id = ? and types = ? and level = ?",
        self.category_id, PracticeSentence::TYPES[:SENTENCE], all_start_level[1]])
    sentence_list = practice_sentences.collect { |s| s.id }
    listens = PracticeSentence.find(:all, :select => "id",
      :conditions => ["category_id = ? and types = ? and level = ?",
        self.category_id, PracticeSentence::TYPES[:LINSTEN], all_start_level[2]])
    listen_list = listens.collect { |l| l.id }
    return {:word => word_list, :practice_sentences => sentence_list, :listens => listen_list, :levels => all_start_level}
  end

  #更新用户的进步曲线 y=ax  y最大值是测试成绩跟预期成绩的差值，x最大是学习期限
  def show_user_score(current_day, total_day)
    leave_score = self.target_score - self.start_score
    today_score = self.target_score
    if current_day < total_day
      today_score = self.start_score + (leave_score/total_day)*current_day
    end
    return today_score
  end
end
