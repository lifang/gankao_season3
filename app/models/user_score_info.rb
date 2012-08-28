# encoding: utf-8
class UserScoreInfo < ActiveRecord::Base
  belongs_to :user
  belongs_to :category
  
  MAX_SCORE = {:CET4 => 550, :CET6 => 550, :GRADUATE => 75} #各个科目用我们系统复习所能达到的最高成绩
  MODULUS_PERCENT = {:LOW => 0.2, :NOMAL => 0.5, :HIGH => 1}  # 0~20%低分， 21%~50%稍低， 51%~100%正常
  MODULUS = {:LOW => 2, :NOMAL => 1, :HIGH => 0.5}  #低分， 稍低， 正常
  PASS_SCORE = {:CET4 => 425, :CET6 => 425, :GRADUATE => 55} #各个科目过关成绩


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
  def show_user_score(current_package, total_package)
    leave_score = self.target_score - self.start_score
    today_score = self.target_score
    if current_package < total_package
      today_score = self.start_score + (leave_score*(current_package.to_f/total_package)).round
    end
    return today_score
  end

  #根据用户的测试成绩计算他的时间系数
  def set_user_modulus
    max_score = UserScoreInfo.return_max_score(self.category_id)
    percent = self.start_score.to_f/max_score
    self.mudulus = if percent <= MODULUS_PERCENT[:LOW]
      MODULUS[:LOW]
    elsif percent > MODULUS_PERCENT[:LOW] and percent <= MODULUS_PERCENT[:NOMAL]
      MODULUS[:NOMAL]
    else
      MODULUS[:HIGH]
    end
    self.save
  end

  def self.return_max_score(category_id)
    return case category_id
    when Category::TYPE[:CET4]
      MAX_SCORE[:CET4]
    when Category::TYPE[:CET6]
      MAX_SCORE[:CET6]
    when Category::TYPE[:GRADUATE]
      MAX_SCORE[:GRADUATE]
    end
  end
  
end
