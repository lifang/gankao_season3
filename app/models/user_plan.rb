# encoding: utf-8
class UserPlan < ActiveRecord::Base
  belongs_to :category
  belongs_to :user

  require 'rexml/document'
  include REXML

  CET46_PLANS = {1 => 60, 2 => 45, 3 => 30}
  GRADUATE_PLANS = {1 => 90, 2 => 75, 3 => 60, 4 => 45}
  PER_TIME = {:WORD => 60, :SENTENCE => 60, :LISTEN => 30, :READ => 300, :WRITE => 300, :TRANSLATE => 60,:DICTATION => 60}  #单位 秒
  PER_ITEMS = {:WORD => 100, :SENTENCE => 100, :LISTEN => 10, :READ => 6, :WRITE => 6, :TRANSLATE => 10,:DICTATION => 10}  #单位 秒
  PER_PACKAGE_TIME = 120 #单位分钟
  TRUE_PAPER_TIME = 375 #单位分钟
  
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
      p 'error'
      return nil
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
  def self.target_level_report(target_score,category_id)
    category = Category::FLAG[category_id]
    max_score = Examination::MAX_SCORE[:"#{category}"]
    return nil unless word = calculate_target_level(target_score, max_score, Word::MAX_LEVEL[:"#{category}"])
    return nil unless sentence = calculate_target_level(target_score, max_score, PracticeSentence::SENTENCE_MAX_LEVEL[:"#{category}"])
    if category_id == (Category::TYPE[:CET4] || Category::TYPE[:CET6])
      return nil unless listen = calculate_target_level(target_score, max_score, PracticeSentence::LISTEN_MAX_LEVEL[:"#{category}"])
      return nil unless translate = calculate_target_level(target_score, max_score, PracticeSentence::TRANSLATE_MAX_LEVEL[:"#{category}"])
      return nil unless dictation = calculate_target_level(target_score, max_score, PracticeSentence::DICTATION_MAX_LEVEL[:"#{category}"])
    end
    return nil unless read = calculate_target_level(target_score, max_score, Tractate::READ_MAX_LEVEL[:"#{category}"])
    return nil unless write = calculate_target_level(target_score, max_score, Tractate::WRITE_MAX_LEVEL[:"#{category}"])

    if category_id == (Category::TYPE[:CET4] || Category::TYPE[:CET6])
      return {:WORD => word, :SENTENCE => sentence, :LISTEN => listen, :READ => read, :WRITE => write, :TRANSLATE => translate, :DICTATION => dictation}
    else
      return {:WORD => word, :SENTENCE => sentence, :READ => read, :WRITE => write}
    end
  end

  #累计用户设定目标需要的时长/每项的题目数量（返回 单位值：分钟）
  def self.calculate_user_plan_info(uid, category_id, target_score, flag)
    user = UserScoreInfo.where(["user_id = ? and category_id = ?", uid, category_id]).first
    return if user.nil?
    return nil unless target_level_hash = target_level_report(target_score, category_id)
    p "-->#{target_level_hash}"
    word_num = (target_level_hash[:WORD] - user.all_start_level.split(",")[0].to_i)*PER_ITEMS[:WORD]
    sentence_num = (target_level_hash[:SENTENCE] - user.all_start_level.split(",")[1].to_i)*PER_ITEMS[:SENTENCE]
    read_num = target_level_hash[:READ]*PER_ITEMS[:READ]
    write_num = target_level_hash[:WRITE]*PER_ITEMS[:WRITE]
    if category_id == (Category::TYPE[:CET4] || Category::TYPE[:CET6])
      listen_num = (target_level_hash[:LISTEN] - user.all_start_level.split(",")[2].to_i)*PER_ITEMS[:LISTEN]
      translate_num = target_level_hash[:TRANSLATE]*PER_ITEMS[:TRANSLATE]
      dictation_num = target_level_hash[:DICTATION]*PER_ITEMS[:DICTATION]
      part1  = word_num*PER_TIME[:WORD]
      part1 += sentence_num*PER_TIME[:SENTENCE]
      part1 += listen_num*PER_TIME[:LISTEN]
      part2  = read_num*PER_TIME[:READ]
      part2 += write_num*PER_TIME[:WRITE]
      part2 += translate_num*PER_TIME[:TRANSLATE]
      part3  = dictation_num*PER_TIME[:DICTATION]
      result = {:ONE => part1/60, :TWO => part2/60, :THREE => part3/60 + TRUE_PAPER_TIME,
        :ALL => (part1 + part2 + part3)/60 +TRUE_PAPER_TIME,
        :WORD => word_num, :SENTENCE => sentence_num, :READ => read_num, :WRITE => write_num,
        :LISTEN => listen_num, :TRANSLATE => translate_num, :DICTATION => dictation_num
      }
    elsif category_id == Category::TYPE[:GRADUATE]
      part1  = word_num*PER_TIME[:WORD]
      part1 += sentence_num*PER_TIME[:SENTENCE]
      part2  = read_num*PER_TIME[:READ]
      part2 += write_num*PER_ITEMS[:WRITE]*PER_TIME[:WRITE]

      result = {:ONE => part1/60, :TWO => part2/60, :THREE => TRUE_PAPER_TIME,
        :ALL => (part1 + part2)/60 +TRUE_PAPER_TIME,
        :WORD => word_num, :SENTENCE => sentence_num, :READ => read_num, :WRITE => write_num
      }
    end

    #判断是否 可行，否则系统计算可达到的情况
    left_mis = package_sys_time(package_level(category_id))
    p "user time-#{result[:ALL]}  sys left time-#{left_mis}"
    if result[:ALL] <= left_mis || flag == 1
      return result
    else
      p left_mis.to_f/result[:ALL]
      sys_provide_score = (target_score*left_mis/result[:ALL]).to_i
      p "sys provider-->#{sys_provide_score}"
      calculate_user_plan_info(uid, category_id, sys_provide_score, 1)
    end
  end

  #确定计划的天数(即：包的数量)
  #根据不同科目 下给定的区间值选择最优值
  def self.package_level(category_id)
    today = Time.now.strftime("%Y-%m-%d")
    day = (Constant::DEAD_LINE[:"#{Category::FLAG[category_id]}"].to_time - today.to_time)/86400
    p "left day #{day}"
    if category_id == (Category::TYPE[:CET4] || Category::TYPE[:CET6])
      CET46_PLANS.each { |k,v|
        return v if v <= day
      }
    elsif category_id == Category::TYPE[:GRADUATE]
      GRADUATE_PLANS.each { |k,v|
        return v if v <= day
      }
    end
  end

  #计算任务包的系统时间(返回 单位值：分钟)
  def self.package_sys_time(package_num)
    return package_num*UserPlan::PER_PACKAGE_TIME
  end
  
  def plan_list
    plan_list = self.plan_url
    file=File.open "#{Constant::PUBLIC_PATH}#{self.paper_url}"
    doc = Document.new(file)
    file.close

  end
end
