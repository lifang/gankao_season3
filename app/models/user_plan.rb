# encoding: utf-8
class UserPlan < ActiveRecord::Base
  belongs_to :category
  belongs_to :user

  require 'rexml/document'
  include REXML

  CET46_PLANS = {1 => 30, 2 => 45, 3 => 60}
  GRADUATE_PLANS = {1 => 45, 2 => 60, 3 => 75, 4 => 90}
  PER_TIME = {:WORD => 60, :SENTENCE => 60, :LISTEN => 30, :READ => 300, :WRITE => 300, :TRANSLATE => 60,:DICTATION => 60}  #单位 秒
  PER_ITEMS = {:WORD => 100, :SENTENCE => 100, :LISTEN => 10, :READ => 6, :WRITE => 6, :TRANSLATE => 10,:DICTATION => 10}  #单位 秒

  #根据前测与用户期望 计算需要达到的等级
  def self.calculate_target_level(target_score, max_score, max_level)
    is_less_middle = false
    if target_score*2 > max_score.to_i
      is_less_middle = false
      target_score = max_score - target_score
    else
      is_less_middle = true
      target_score = target_score
    end
    y = max_level%2 == 0 ? max_level + 1 : max_level # 41
    x = (y-1)*0.5  # 20
    total_area = max_level%2 == 0 ? x*y-y/x*0.5 : x*y
    solute_quadratic(max_level*max_score, -max_level*max_score, max_level*max_level*0.25-target_score*total_area*max_level,is_less_middle,max_level)
  end

  #求解 一元二次方程 ax(2) + bx + c = 0
  def self.solute_quadratic(a, b, c, is_less_middle,max_level)
    if b*b-4*a*c < 0
      p "error"
    else
      if is_less_middle
        level = ((-b+Math.sqrt(b*b-4*a*c))/(2*a)).to_i.abs
      else
        level = ((-b-Math.sqrt(b*b-4*a*c))/(2*a)).to_i.abs
        level = max_level  - level
      end
      return level.to_i
    end
  end

  # 计算各个练习需要达到的等级
  def self.target_level_report(target_score,category)
    max_score = Examination::MAX_SCORE[:"#{category}"]
    #单词
    word = calculate_target_level(target_score, max_score, Word::MAX_LEVEL[:"#{category}"])
    #句子
    sentence = calculate_target_level(target_score, max_score, PracticeSentence::SENTENCE_MAX_LEVEL[:"#{category}"])
    #听力
    if category.upcase == ('CET4' || 'CET6')
      listen = calculate_target_level(target_score, max_score, PracticeSentence::LISTEN_MAX_LEVEL[:"#{category}"])
    end
    #阅读
    read = calculate_target_level(target_score, max_score, Tractate::READ_MAX_LEVEL[:"#{category}"])
    #写作
    write = calculate_target_level(target_score, max_score, Tractate::WRITE_MAX_LEVEL[:"#{category}"])
    #翻译
    if category.upcase == ('CET4' || 'CET6')
      translate = calculate_target_level(target_score, max_score, PracticeSentence::TRANSLATE_MAX_LEVEL[:"#{category}"])
    end
    #听写
    if category.upcase == ('CET4' || 'CET6')
      dictation = calculate_target_level(target_score, max_score, PracticeSentence::DICTATION_MAX_LEVEL[:"#{category}"])
    end

    if category != 'GRADUATE'
      return {:WORD => word, :SENTENCE => sentence, :LISTEN => listen, :READ => read, :WRITE => write, :TRANSLATE => translate, :DICTATION => dictation}
    else
      return {:WORD => word, :SENTENCE => sentence, :READ => read, :WRITE => write}
    end
  end

  #累计用户设定目标需要的时长
  def self.calculate_user_plan_times(uid, target_level_hash)
    user = UserScoreInfo.find(uid)
    return if user.nil?
    if user.category.name.upcase == ('CET4' || 'CET6')
      times = (target_level_hash[:WORD] - user.all_start_level.split(",")[0].to_i)*PER_ITEMS[:WORD]*PER_TIME[:WORD]
      times += (target_level_hash[:SENTENCE] - user.all_start_level.split(",")[1].to_i)*PER_ITEMS[:SENTENCE]*PER_TIME[:SENTENCE]
      times += (target_level_hash[:LISTEN] - user.all_start_level.split(",")[2].to_i)*PER_ITEMS[:LISTEN]*PER_TIME[:LISTEN]
      times += target_level_hash[:READ]*PER_ITEMS[:READ]*PER_TIME[:READ]
      times += target_level_hash[:WRITE]*PER_ITEMS[:WRITE]*PER_TIME[:WRITE]
      times += target_level_hash[:TRANSLATE]*PER_ITEMS[:TRANSLATE]*PER_TIME[:TRANSLATE]
      times += target_level_hash[:DICTATION]*PER_ITEMS[:DICTATION]*PER_TIME[:DICTATION]
    elsif user.category.name.upcase == 'GRADUATE'
      times = (target_level_hash[:WORD] - user.all_start_level.split(",")[0].to_i)*PER_ITEMS[:WORD]*PER_TIME[:WORD]
      times += (target_level_hash[:SENTENCE] - user.all_start_level.split(",")[1].to_i)*PER_ITEMS[:SENTENCE]*PER_TIME[:SENTENCE]
      times += target_level_hash[:READ]*PER_ITEMS[:READ]*PER_TIME[:READ]
      times += target_level_hash[:WRITE]*PER_ITEMS[:WRITE]*PER_TIME[:WRITE]
    end
    return times/60
  end

  #确定 计划包的 天数
  def self.package_level(category)

  end
  
  def plan_list
    plan_list = self.plan_url
    file=File.open "#{Constant::PUBLIC_PATH}#{self.paper_url}"
    doc = Document.new(file)
    file.close

  end
end
