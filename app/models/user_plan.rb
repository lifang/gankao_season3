# encoding: utf-8
class UserPlan < ActiveRecord::Base
  belongs_to :category
  belongs_to :user

  require 'rexml/document'
  include REXML

  PER_PACKAGE_TIME = 120 #单位分钟
  TRUE_PAPER_TIME = 375 #单位分钟
  PAPER_NUM = 276 #三套试卷共276题

  
  CET46_PLANS = {1 => 60, 2 => 45, 3 => 30}
  GRADUATE_PLANS = {1 => 90, 2 => 75, 3 => 60, 4 => 45}
  CHAPTER_TYPE = {:WORD => "word", :SENTENCE => "sentence", :LINSTEN => "linsten", :READ => "read",
    :TRANSLATE => "translate", :DICTATION => "dictation", :WRITE => "write", :SIMILARITY => "similarity"}#单词、句子、听力、阅读、翻译、听写、写作
  CHAPTER = {:cha1 => "基础", :cha2 => "综合", :cha3 => "冲刺"} #三个阶段的名称
  CHAPTER_TYPE_NUM = {:WORD => 0, :SENTENCE => 1, :LINSTEN => 2, :READ => 3,
    :TRANSLATE => 4, :DICTATION => 5, :WRITE => 6,:SIMILAR =>7}#单词、句子、听力、阅读、翻译、听写、写作
  REPEAT_TIME = {:WORD => [1, 0, 2, 1], :OTHER => [2, 0]} #每个练习的重复间隔时间和重复次数
  PLAN_STATUS = {:FINISHED => 1, :UNFINISHED => 0}

  PER_TIME = {:WORD => 60, :SENTENCE => 60, :LISTEN => 30, :READ => 300, :WRITE => 300, :TRANSLATE => 60,:DICTATION => 60}  #单位 秒
  PER_ITEMS = {:WORD => 100, :SENTENCE => 100, :LISTEN => 10, :READ => 6, :WRITE => 6, :TRANSLATE => 10,:DICTATION => 10}  #单位 秒

  LEVEL_COUNT = {:WORD => 100, :SENTENCE => 100, :LINSTEN => 10, :READ => 6,
    :TRANSLATE => 100, :DICTATION => 10, :WRITE => 6}  #各种练习每个level的个数

  
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
    y = max_level + 1
    x = max_level
    total_area = x*y/2
    #return target_score > 0 ?
    #solute_quadratic(max_level*max_score, -max_level*max_score,
    #max_level*max_level*0.25-target_score*total_area*max_level,is_less_middle,max_level) : max_level
    return target_score > 0 ? solute_quadratic(max_score, -(max_level+0.5)*max_score,
      0.25*(max_level+1)*max_level*max_score-target_score*total_area, is_less_middle, max_level) : max_level
  end

  #求解 一元二次方程 ax(2) + bx + c = 0
  def self.solute_quadratic(a, b, c, is_less_middle, max_level)
    if b*b-4*a*c < 0
      p 'error'
      return nil
    else
      if is_less_middle
        level = ((-b-Math.sqrt(b*b-4*a*c))/(2*a)).to_i.abs
        level = max_level.to_f/2 - level
      else       
        level = ((-b-Math.sqrt(b*b-4*a*c))/(2*a)).to_i.abs
        level = max_level.to_f/2 + level
      end
      return level.to_i
    end
  end

  # 计算各个练习需要达到的等级
  def self.target_level_report(target_score,category_id)
    category = Category::FLAG[category_id]
    max_score = UserScoreInfo::MAX_SCORE[:"#{category}"]
    return nil unless word = calculate_target_level(target_score, max_score, Word::MAX_LEVEL[:"#{category}"])
    return nil unless sentence = calculate_target_level(target_score, max_score,
      PracticeSentence::SENTENCE_MAX_LEVEL[:"#{category}"])
    if category_id == Category::TYPE[:CET4] or  category_id == Category::TYPE[:CET6]
      return nil unless listen = calculate_target_level(target_score, max_score,
        PracticeSentence::LISTEN_MAX_LEVEL[:"#{category}"])
      return nil unless translate = calculate_target_level(target_score, max_score,
        PracticeSentence::TRANSLATE_MAX_LEVEL[:"#{category}"])
      return nil unless dictation = calculate_target_level(target_score, max_score,
        PracticeSentence::DICTATION_MAX_LEVEL[:"#{category}"])
    end
    return nil unless read = calculate_target_level(target_score, max_score, Tractate::READ_MAX_LEVEL[:"#{category}"])
    return nil unless write = calculate_target_level(target_score, max_score, Tractate::WRITE_MAX_LEVEL[:"#{category}"])
    if category_id == Category::TYPE[:CET4] or  category_id == Category::TYPE[:CET6]
      return {:WORD => word, :SENTENCE => sentence, :LISTEN => listen, :READ => read,
        :WRITE => write, :TRANSLATE => translate, :DICTATION => dictation}
    else
      return {:WORD => word, :SENTENCE => sentence, :READ => read, :WRITE => write}
    end
  end

  #累计用户设定目标需要的时长/每项的题目数量（返回 单位值：分钟）
  def self.calculate_user_plan_info(all_start_level, category_id, target_score)
    target_level_hash = target_level_report(target_score, category_id)
    s_word = all_start_level.split(",")[0].to_i*PER_ITEMS[:WORD]
    s_sentence = all_start_level.split(",")[1].to_i*PER_ITEMS[:SENTENCE]
    s_listen = all_start_level.split(",")[2].to_i*PER_ITEMS[:LISTEN]
    word_num = target_level_hash[:WORD]*PER_ITEMS[:WORD] - s_word > 0 ?
      (target_level_hash[:WORD]*PER_ITEMS[:WORD] - s_word) : PER_ITEMS[:WORD]
    sentence_num = target_level_hash[:SENTENCE]*PER_ITEMS[:SENTENCE] - s_sentence > 0 ?
      (target_level_hash[:SENTENCE]*PER_ITEMS[:SENTENCE] - s_sentence) : PER_ITEMS[:SENTENCE]
    read_num = target_level_hash[:READ]*PER_ITEMS[:READ]
    write_num = target_level_hash[:WRITE]*PER_ITEMS[:WRITE]
    if category_id == Category::TYPE[:CET4] or  category_id == Category::TYPE[:CET6]
      listen_num = target_level_hash[:LISTEN]*PER_ITEMS[:LISTEN] - s_listen > 0 ?
        (target_level_hash[:LISTEN]*PER_ITEMS[:LISTEN] - s_listen) : PER_ITEMS[:LISTEN]
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
    error_time = category_id == Category::TYPE[:GRADUATE] ? 300 :
      (category_id == Category::TYPE[:CET4] ? 100 : 300)
    if result[:ALL] <= (left_mis + error_time)
      return result
    else
      sys_provide_plan(s_word, s_sentence, s_listen, result, left_mis, category_id)
    end
  end

  #根据给定时间 计算可达目标
  def UserPlan.sys_provide_plan(s_word, s_sentence, s_listen, user_plan, sys_provide_time, category_id)
    precent = (sys_provide_time-TRUE_PAPER_TIME).to_f/(user_plan[:ALL]-TRUE_PAPER_TIME)
    word_num = (user_plan[:WORD] * precent).to_i
    sentence_num = (user_plan[:SENTENCE] * precent).to_i
    read_num = (user_plan[:READ] * precent).to_i
    write_num = (user_plan[:WRITE] * precent).to_i
    if category_id == Category::TYPE[:CET4] or  category_id == Category::TYPE[:CET6]
      listen_num = (user_plan[:LISTEN] * precent).to_i
      translate_num = (user_plan[:TRANSLATE] * precent).to_i
      dictation_num = (user_plan[:DICTATION] * precent).to_i
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
    else
      part1  = word_num*PER_TIME[:WORD]
      part1 += sentence_num*PER_TIME[:SENTENCE]
      part2  = read_num*PER_TIME[:READ]
      part2 += write_num*PER_ITEMS[:WRITE]*PER_TIME[:WRITE]
      result = {:ONE => part1/60, :TWO => part2/60, :THREE => TRUE_PAPER_TIME,
        :ALL => (part1 + part2)/60 +TRUE_PAPER_TIME,
        :WORD => word_num, :SENTENCE => sentence_num, :READ => read_num, :WRITE => write_num
      }
    end
    result[:TARGET_SCORE] = sys_provide_score_report(s_word, s_sentence, s_listen, result,category_id)
    return result
  end

  #根据计划计算 预计分数
  def UserPlan.sys_provide_score_report(s_word, s_sentence, s_listen, user_plan,category_id)
    if category_id == Category::TYPE[:CET4] or  category_id == Category::TYPE[:CET6]
      score = sys_provide_score((user_plan[:WORD] + s_word).to_f/PER_ITEMS[:WORD],
        Word::MAX_LEVEL[:"#{Category::FLAG[category_id]}"], category_id, 0.15)
      score += sys_provide_score((user_plan[:SENTENCE] + s_sentence).to_f/PER_ITEMS[:SENTENCE],
        PracticeSentence::SENTENCE_MAX_LEVEL[:"#{Category::FLAG[category_id]}"], category_id, 0.2)
      score += sys_provide_score((user_plan[:LISTEN] + s_listen).to_f/PER_ITEMS[:LISTEN],
        PracticeSentence::LISTEN_MAX_LEVEL[:"#{Category::FLAG[category_id]}"], category_id, 0.15)
      score += sys_provide_score(user_plan[:TRANSLATE].to_f/PER_ITEMS[:TRANSLATE],
        PracticeSentence::TRANSLATE_MAX_LEVEL[:"#{Category::FLAG[category_id]}"], category_id, 0.2)
      score += sys_provide_score(user_plan[:DICTATION].to_f/PER_ITEMS[:DICTATION],
        PracticeSentence::DICTATION_MAX_LEVEL[:"#{Category::FLAG[category_id]}"], category_id, 0.1)
      score += sys_provide_score(user_plan[:READ].to_f/PER_ITEMS[:READ],
        Tractate::READ_MAX_LEVEL[:"#{Category::FLAG[category_id]}"], category_id, 0.05)
      score += sys_provide_score(user_plan[:WRITE].to_f/PER_ITEMS[:WRITE],
        Tractate::WRITE_MAX_LEVEL[:"#{Category::FLAG[category_id]}"], category_id, 0.1)
      score += UserScoreInfo::MAX_SCORE[:"#{Category::FLAG[category_id]}"]*0.05
    else
      score = sys_provide_score((user_plan[:WORD] + s_word).to_f/PER_ITEMS[:WORD],
        Word::MAX_LEVEL[:"#{Category::FLAG[category_id]}"], category_id, 0.2)
      score += sys_provide_score((user_plan[:SENTENCE] + s_sentence).to_f/PER_ITEMS[:SENTENCE],
        PracticeSentence::SENTENCE_MAX_LEVEL[:"#{Category::FLAG[category_id]}"], category_id, 0.25)
      score += sys_provide_score(user_plan[:READ].to_f/PER_ITEMS[:READ],
        Tractate::READ_MAX_LEVEL[:"#{Category::FLAG[category_id]}"], category_id, 0.3)
      score += sys_provide_score(user_plan[:WRITE].to_f/PER_ITEMS[:WRITE],
        Tractate::WRITE_MAX_LEVEL[:"#{Category::FLAG[category_id]}"], category_id, 0.15)
      score += UserScoreInfo::MAX_SCORE[:"#{Category::FLAG[category_id]}"]*0.1
    end
  end

  #根据计划计算 每一项所占的预计分数
  def UserPlan.sys_provide_score(target_level, max_level, category_id, score_precent)
    category = Category::FLAG[category_id]
    max_score = UserScoreInfo::MAX_SCORE[:"#{category}"]    
    y = max_level + 1
    x = (y-1)*0.5
    total_area = x*y
    if target_level*2 > max_level
      #在正轴
      return max_score*score_precent*(total_area - 0.5*(max_level-target_level)*(-2*(target_level-max_level/2)+(max_level+1)))/total_area
    elsif target_level*2 == max_level
      return max_score*score_precent*0.5
    else
      return max_score*score_precent*(0.5*target_level*(2*(-max_level/2+target_level)+(max_level+1)))/total_area
    end
  end
  
  #确定计划的天数(即：包的数量)
  #根据不同科目 下给定的区间值选择最优值
  def UserPlan.package_level(category_id)
    today = Time.now.strftime("%Y-%m-%d")
    day = (Constant::DEAD_LINE[:"#{Category::FLAG[category_id]}"].to_time - today.to_time)/86400
    if category_id == Category::TYPE[:CET4] or  category_id == Category::TYPE[:CET6]
      CET46_PLANS.each { |k,v|
        return v if v <= day
      }
    elsif category_id == Category::TYPE[:GRADUATE]
      GRADUATE_PLANS.each { |k,v|
        return v if v <= day
      }
    end
    return day
  end

  #计算任务包的系统时间(返回 单位值：分钟)
  def UserPlan.package_sys_time(package_num)
    return package_num*PER_PACKAGE_TIME
  end

  def plan_list_xml
    file=File.open "#{Constant::PUBLIC_PATH}#{self.plan_url}"
    doc = Document.new(file)
    file.close
    return doc
  end

  #返回复习计划的列表结构为：[[可开启的任务包]， [单词，句子，听力，时间段]， [阅读，翻译，听写，时间段]， [写作，时间段]]
  def get_plan_list(category_id)
    doc = self.plan_list_xml
    chapter1 = doc.root.elements["plan"].elements["info"].elements["chapter1"]
    chapter2 = doc.root.elements["plan"].elements["info"].elements["chapter2"]
    chapter3 = doc.root.elements["plan"].elements["info"].elements["chapter3"]
    if category_id == Category::TYPE[:GRADUATE]
      plan_info = {:current => doc.root.elements["plan"].elements["current"].text.to_i,
      :word => chapter1.attributes[CHAPTER_TYPE[:WORD]].to_i, :sentence => chapter1.attributes[CHAPTER_TYPE[:SENTENCE]].to_i,
      :cha1_days => chapter1.attributes["days"].to_i,
      :read => chapter2.attributes[CHAPTER_TYPE[:READ]].to_i, :write => chapter2.attributes[CHAPTER_TYPE[:WRITE]].to_i,
      :cha2_days => chapter2.attributes["days"].to_i,
      :similarity => chapter3.attributes[CHAPTER_TYPE[:SIMILARITY]].to_i,
      :cha3_days => chapter3.attributes["days"].to_i}
    else
      plan_info = {:current => doc.root.elements["plan"].elements["current"].text.to_i,
      :word => chapter1.attributes[CHAPTER_TYPE[:WORD]].to_i, :sentence => chapter1.attributes[CHAPTER_TYPE[:SENTENCE]].to_i,
      :linsten => chapter1.attributes[CHAPTER_TYPE[:LINSTEN]].to_i, :cha1_days => chapter1.attributes["days"].to_i,
      :read => chapter2.attributes[CHAPTER_TYPE[:READ]].to_i, :translate => chapter2.attributes[CHAPTER_TYPE[:TRANSLATE]].to_i,
      :dictation => chapter2.attributes[CHAPTER_TYPE[:DICTATION]].to_i, :cha2_days => chapter2.attributes["days"].to_i,
      :write => chapter3.attributes[CHAPTER_TYPE[:WRITE]].to_i, :similarity => chapter3.attributes[CHAPTER_TYPE[:SIMILARITY]].to_i,
      :cha3_days => chapter3.attributes["days"].to_i}
    end
    return plan_info
  end

  #生成初始计划
  def self.init_plan(user_score_info, data_info, user_id, category_id)
    user_plan = UserPlan.find_by_category_id_and_user_id(category_id,user_id)    
    UserPlan.transaction do
      user_plan = UserPlan.create(:category_id => category_id, :user_id => user_id, :days => data_info[:DAYS]) unless user_plan
      user_plan.create_plan_url(user_plan.xml_content(user_score_info.get_start_level,
          user_plan.return_chapter_data(data_info, category_id), category_id),
        "/" + category_id.to_s + "_" + user_plan.id.to_s)
    end
    return user_plan
  end


  def create_plan_url(str, path, super_path = "plan_xmls")
    file_name = self.write_file(str, path, super_path)
    self.plan_url = file_name
    self.save
  end

  #返回各个部分的时间
  def return_chapter_data(data_info, category_id)
    first_chapter = ((data_info[:ONE].to_f/data_info[:ALL].to_i)*data_info[:DAYS]).ceil    
    second_chapter = ((data_info[:TWO].to_f/data_info[:ALL].to_i)*data_info[:DAYS]).ceil    
    third_chapter = data_info[:DAYS] - first_chapter - second_chapter    
    word_avg = (data_info[:WORD].to_f/first_chapter).ceil    
    sentence_avg = (data_info[:SENTENCE].to_f/first_chapter).ceil
    read_avg = (data_info[:READ].to_f/second_chapter).ceil
    similarity_avg = PAPER_NUM/third_chapter
    if category_id == Category::TYPE[:GRADUATE]
      write_avg = (data_info[:WRITE].to_f/second_chapter).ceil
      chapter_info = { :first_chapter => first_chapter, :second_chapter => second_chapter, :third_chapter => third_chapter,
        :word_avg => word_avg, :sentence_avg => sentence_avg, :read_avg => read_avg,  :write_avg => write_avg,
        :similarity_avg => similarity_avg }
    else
      listen_avg = (data_info[:LISTEN].to_f/first_chapter).ceil      
      translate_avg = (data_info[:TRANSLATE].to_f/second_chapter).ceil
      dictation_avg = (data_info[:DICTATION].to_f/second_chapter).ceil
      write_avg = (data_info[:WRITE].to_f/third_chapter).ceil
      chapter_info = { :first_chapter => first_chapter, :second_chapter => second_chapter, :third_chapter => third_chapter,
        :word_avg => word_avg, :sentence_avg => sentence_avg, :listen_avg => listen_avg, :read_avg => read_avg,
        :translate_avg => translate_avg, :dictation_avg => dictation_avg, :write_avg => write_avg,
        :similarity_avg => similarity_avg }
    end
    return chapter_info
  end

  #创建xml文件 tiku_hash = get_start_level, chapter_info = return_chapter_data
  def xml_content(tiku_hash, chapter_info, category_id)
    task_info = self.return_task(tiku_hash, chapter_info, category_id)
    content = "<?xml version='1.0' encoding='UTF-8'?>"
    if category_id == Category::TYPE[:GRADUATE]
      chapter1 = "<chapter1 word='#{chapter_info[:word_avg]}' sentence='#{chapter_info[:sentence_avg]}' days='#{chapter_info[:first_chapter]}' />"
      chapter2 = "<chapter2 read='#{chapter_info[:read_avg]}' write='#{chapter_info[:write_avg]}' days='#{chapter_info[:second_chapter]}' />"
      chapter3 = "<chapter3 similarity='#{chapter_info[:similarity_avg]}'  days='#{chapter_info[:third_chapter]}' />"
    else
      chapter1 = "<chapter1 word='#{chapter_info[:word_avg]}' sentence='#{chapter_info[:sentence_avg]}' linsten='#{chapter_info[:listen_avg]}' days='#{chapter_info[:first_chapter]}' />"
      chapter2 = "<chapter2 read='#{chapter_info[:read_avg]}' translate='#{chapter_info[:translate_avg]}' dictation='#{chapter_info[:dictation_avg]}' days='#{chapter_info[:second_chapter]}' />"
      chapter3 = "<chapter3 write='#{chapter_info[:write_avg]}' similarity='#{chapter_info[:similarity_avg]}'  days='#{chapter_info[:third_chapter]}' />"
    end
    content += "<root><plan><current>1</current><info>#{chapter1}#{chapter2}#{chapter3}</info><_1 status='0'>"
    
    part1 = "<part type='#{CHAPTER_TYPE_NUM[:WORD]}' status='0'>#{task_info[:word_info]}</part>" unless task_info[:word_info].empty?
    part2 = "<part type='#{CHAPTER_TYPE_NUM[:SENTENCE]}' status='0'>#{task_info[:sentence_info]}</part>" unless task_info[:sentence_info].empty?
    if category_id == Category::TYPE[:GRADUATE]
      content += "#{part1}#{part2}</_1>"
    else
      part3 = "<part type='#{CHAPTER_TYPE_NUM[:LINSTEN]}' status='0'>#{task_info[:listen_info]}</part>" unless task_info[:listen_info].empty?
      content += "#{part1}#{part2}#{part3}</_1>"
    end
    word = "<part type='#{CHAPTER_TYPE_NUM[:WORD]}' num='#{chapter_info[:word_avg]}'/>" if chapter_info[:word_avg] > 0
    sentence = "<part type='#{CHAPTER_TYPE_NUM[:SENTENCE]}' num='#{chapter_info[:sentence_avg]}'/>" if chapter_info[:sentence_avg] > 0
    read = "<part type='#{CHAPTER_TYPE_NUM[:READ]}' num='#{chapter_info[:read_avg]}'/>" if chapter_info[:read_avg] > 0
    write = "<part type='#{CHAPTER_TYPE_NUM[:WRITE]}' num='#{chapter_info[:write_avg]}'/>" if chapter_info[:write_avg] > 0
    similarity = "<part type='#{CHAPTER_TYPE_NUM[:SIMILAR]}' num='#{chapter_info[:similarity_avg]}'/>" if chapter_info[:similarity_avg] > 0
    if category_id != Category::TYPE[:GRADUATE]
      listen = "<part type='#{CHAPTER_TYPE_NUM[:LINSTEN]}' num='#{chapter_info[:listen_avg]}'/>" if chapter_info[:listen_avg] > 0
      translate = "<part type='#{CHAPTER_TYPE_NUM[:TRANSLATE]}' num='#{chapter_info[:translate_avg]}'/>" if chapter_info[:translate_avg] > 0
      dictation = "<part type='#{CHAPTER_TYPE_NUM[:DICTATION]}' num='#{chapter_info[:dictation_avg]}'/>" if chapter_info[:dictation_avg] > 0
    end
    (2..chapter_info[:first_chapter].to_i).each {|i|
      content += ((category_id == Category::TYPE[:GRADUATE]) ? "<_#{i} status='0'>#{word}#{sentence}</_#{i}>" : "<_#{i} status='0'>#{word}#{sentence}#{listen}</_#{i}>")
    }
    ((chapter_info[:first_chapter].to_i+1)..(chapter_info[:first_chapter].to_i+chapter_info[:second_chapter].to_i)).each{|i|
      content += ((category_id == Category::TYPE[:GRADUATE]) ? "<_#{i} status='0'>#{read}#{write}</_#{i}>" : "<_#{i} status='0'>#{read}#{translate}#{dictation}</_#{i}>")
    }
    ((chapter_info[:first_chapter].to_i+chapter_info[:second_chapter].to_i+1)..(chapter_info[:first_chapter].to_i+chapter_info[:second_chapter].to_i+chapter_info[:third_chapter].to_i)).each{|i|
      content += ((category_id == Category::TYPE[:GRADUATE]) ? "<_#{i} status='0'>#{similarity}</_#{i}>" : "<_#{i} status='0'>#{write}#{similarity}</_#{i}>")
    }
    tiku_listen = (category_id == Category::TYPE[:GRADUATE]) ? "" : "<part type='#{CHAPTER_TYPE_NUM[:LINSTEN]}' lv='#{tiku_hash[:levels][2]}' item='#{task_info[:leave_listen].join(",")}'/>"
    content += <<-XML
        </plan>
        <review></review>
        <tiku>
          <part type='#{CHAPTER_TYPE_NUM[:WORD]}' lv='#{tiku_hash[:levels][0]}' item='#{task_info[:leave_word].join(",")}'/>
          <part type='#{CHAPTER_TYPE_NUM[:SENTENCE]}' lv='#{tiku_hash[:levels][1]}' item='#{task_info[:leave_sentence].join(",")}'/>
          #{tiku_listen}
        </tiku>
      </root>
    XML
    
    return content
  end
  
  #返回默认第一个任务，以及剩下的题库的单词 tiku_hash = get_start_level, chapter_info = return_chapter_data
  def return_task(tiku_hash, chapter_info, category_id)
    word_list = proof_code(tiku_hash[:word], chapter_info[:word_avg])
    sentence_list = proof_code(tiku_hash[:practice_sentences], chapter_info[:sentence_avg])
    word_info, sentence_info, listen_info = "", "", ""
    word_list.each { |w| word_info += "<item id='#{w}' is_pass='#{PLAN_STATUS[:UNFINISHED]}' repeat_time='0' step='0' />" }
    sentence_list.each { |s| sentence_info += "<item id='#{s}' is_pass='#{PLAN_STATUS[:UNFINISHED]}' repeat_time='0' step='0' />" }
    if category_id != Category::TYPE[:GRADUATE]
      listen_list = proof_code(tiku_hash[:listens], chapter_info[:listen_avg])
      listen_list.each { |l| listen_info += "<item id='#{l}' is_pass='#{PLAN_STATUS[:UNFINISHED]}' repeat_time='0' step='0' />" }
      task_info = {:word_info => word_info, :sentence_info => sentence_info, :listen_info => listen_info,
        :leave_word => tiku_hash[:word] - word_list, :leave_sentence  => tiku_hash[:practice_sentences] - sentence_list,
        :leave_listen => tiku_hash[:listens] - listen_list}
    else
      task_info = {:word_info => word_info, :sentence_info => sentence_info,
        :leave_word => tiku_hash[:word] - word_list, :leave_sentence  => tiku_hash[:practice_sentences] - sentence_list}
    end    
    return task_info
  end
  
  #写文件
  def write_file(str, path, super_path)
    dir = "#{Rails.root}/public/#{super_path}"
    Dir.mkdir(dir) unless File.directory?(dir)
    unless File.directory?(dir + "/" + Time.now.strftime("%Y-%m"))
      Dir.mkdir(dir + "/" + Time.now.strftime("%Y-%m"))
    end
    file_name = "/" + Time.now.strftime("%Y-%m") + path + ".xml"
    url = dir + file_name
    f=File.new(url,"w+")
    f.write("#{str.force_encoding('UTF-8')}")
    f.close
    return "/#{super_path}" + file_name
  end

  #随机取练习
  def proof_code(chars, len)
    code_array = []
    if len < chars.length
      1.upto(len) {code_array << (chars - code_array)[rand(chars.length - code_array.length)]}
    else
      code_array = chars
    end
    return code_array
  end

  #根据用户完成的任务，更新用户xml
  def update_plan
    doc = self.plan_list_xml
    current_day = doc.root.elements["plan"].elements["current"].text.to_i
    update_review_task(doc, current_day)
    doc.root.elements["plan"].elements["current"].text = current_day + 1
    f = File.new("#{Rails.root}/public" + self.plan_url,"w+")
    f.write("#{doc.to_s.force_encoding('UTF-8')}")
    f.close
  end

  #将需要复习的内容放到review中
  def update_review_task(plan_xml, current_day)
    current_review = plan_xml.root.elements["review"].elements["_#{current_day}"]
    if !current_review.nil? and current_review.has_elements?
      current_review.each_element { |part|
        if part.attributes["type"].to_i == CHAPTER_TYPE_NUM[:WORD] and part.attributes["repeat_time"] == "0"
          self.create_review_task(plan_xml, current_day, REPEAT_TIME[:WORD][2], part, REPEAT_TIME[:WORD][3])
        else
          plan_xml.delete_element(part.xpath)
        end if part.attributes["status"] == "#{PLAN_STATUS[:FINISHED]}"
      }
      plan_xml.root.elements["review"].delete_element(current_review) unless current_review.has_elements?
    end
    current_task = plan_xml.root.elements["plan"].elements["_#{current_day}"]
    if current_task.attributes["status"] == "#{PLAN_STATUS[:FINISHED]}"
      current_task.each_element { |p|
        if current_task.attributes["type"].to_i == CHAPTER_TYPE_NUM[:WORD] #单词
          self.create_review_task(plan_xml, current_day, REPEAT_TIME[:WORD][0], p, REPEAT_TIME[:WORD][1])
        elsif current_task.attributes["type"].to_i != CHAPTER_TYPE_NUM[:READ]
          self.create_review_task(plan_xml, current_day, REPEAT_TIME[:OTHER][0], p, REPEAT_TIME[:OTHER][1])
        end
      }
      plan_xml.delete_element(current_task.xpath)
      update_new_task(plan_xml, current_day)
    end
  end
  
  #将需要新学的内容提到包中
  def update_new_task(plan_xml, current_day)
    next_plan = plan_xml.root.elements["plan"].elements["_#{current_day+1}"]
    unless next_plan.nil?
      tomorrow_task_plan = {}
      tomorrow_task = {}
      next_plan.each_element { |part|
        tomorrow_task_plan[part.attributes["type"].to_i] = part.attributes["num"].to_i
      }
      tiku_hash = {}
      plan_xml.root.elements["tiku"].each_element { |p|
        tiku_hash[p.attributes["type"].to_i] = p
      }
      tomorrow_task_plan.each { |k, v|
        if k == CHAPTER_TYPE_NUM[:SIMILAR]
          next_plan.elements["part[@type='#{k}']"].add_element("item", {"id" => 0, "num" => "#{v}", "is_pass" => "#{PLAN_STATUS[:UNFINISHED]}"})
        else
          if tiku_hash[k].nil? #当题库中是否存在今天要学的内容
            tiku_info = get_new_tiku(k, 1, v)
            new_tiku = tiku_info[0]
            plan_xml.root.elements["tiku"].add_element("part", {"type" => k, "lv" => "#{tiku_info[1]}", "item" => new_tiku.join(",")})
            tiku_hash[k] = plan_xml.root.elements["tiku"].elements["part[@type='#{k}']"]
          end
          tomorrow_task[k] = []
          already_items = tiku_hash[k].attributes["item"].split(",")
          if already_items.any? and already_items.length >= v
            proof_code(already_items, v).each {|i|
              tomorrow_task[k] << i
            }
            tiku_hash[k].attributes["item"] = (already_items - tomorrow_task[k]).join(",")
          else
            tomorrow_task[k] = already_items
            tiku_hash[k].attributes["lv"] = tiku_hash[k].attributes["lv"].to_i + 1
            tiku_info = get_new_tiku(k, tiku_hash[k].attributes["lv"].to_i, (v-already_items.length))
            new_tiku = tiku_info[0]
            tiku_hash[k].attributes["lv"] = tiku_info[1]
            proof_code(new_tiku, (v - already_items.length)).each {|i|
              tomorrow_task[k] << i
            }
            tiku_hash[k].attributes["item"] = (new_tiku - tomorrow_task[k]).join(",")
          end
        end        
      }
      update_new_package(next_plan, tomorrow_task)
    end
  end

  #修改即将要学的包
  def update_new_package(next_plan, tomorrow_task)
    next_plan.each_element { |part|
      part.delete_attribute("num")
      part.add_attribute("status", "#{PLAN_STATUS[:UNFINISHED]}")
      if tomorrow_task[part.attributes["type"].to_i].any?
        tomorrow_task[part.attributes["type"].to_i].each {|i|
          part.add_element("item", {"id" => i, "is_pass" => "#{PLAN_STATUS[:UNFINISHED]}", "repeat_time" => "0", "step" => "0"})
        }
      else
        next_plan.delete_element(part)
      end unless tomorrow_task[part.attributes["type"].to_i].nil?
    }
  end

  #取新的题库
  def get_new_tiku(type, level, practice_num)
    items = []
    if type == CHAPTER_TYPE_NUM[:WORD]
      end_level = practice_num/LEVEL_COUNT[:WORD] + level
      infos = Word.find(:all, :select => "id", :conditions => ["level >= ? and level <= ?", level, end_level])
    elsif type == CHAPTER_TYPE_NUM[:READ] or type == CHAPTER_TYPE_NUM[:WRITE]
      end_level = practice_num/LEVEL_COUNT[:READ] + level
      infos = Tractate.find(:all, :select => "id", :conditions => ["level >= ? and level <= ?", level, end_level])
    else
      end_level = case type
      when CHAPTER_TYPE_NUM[:SENTENCE]
        practice_num/LEVEL_COUNT[:SENTENCE] + level
      when CHAPTER_TYPE_NUM[:TRANSLATE]
        practice_num/LEVEL_COUNT[:SENTENCE] + level
      else
        practice_num/LEVEL_COUNT[:LINSTEN] + level
      end
      sql_type = case type
      when CHAPTER_TYPE_NUM[:SENTENCE]
        PracticeSentence::TYPES[:SENTENCE]
      when CHAPTER_TYPE_NUM[:LINSTEN]
        PracticeSentence::TYPES[:LINSTEN]
      when CHAPTER_TYPE_NUM[:TRANSLATE]
        PracticeSentence::TYPES[:SENTENCE]
      else CHAPTER_TYPE_NUM[:DICTATION]
        PracticeSentence::TYPES[:LINSTEN]
      end
      infos = PracticeSentence.find(:all, :select => "id", :conditions => ["types = ? and level >= ? and level <= ? ",
          sql_type, level, end_level])
    end
    items = infos.collect { |i| i.id }
    return [items, end_level]
  end

  #新建复习节点
  def create_review_task(plan_xml, current_day, days, part, repeat_time)
    next_review = plan_xml.root.elements["review"].elements["_#{current_day.to_i + days}"]
    if next_review.nil?
      next_review = plan_xml.root.elements["review"].add_element("_#{current_day.to_i + days}", {"status" => "#{PLAN_STATUS[:UNFINISHED]}"})
    end
    self.reset_task_item(part, repeat_time)
    next_review.add_element(part)
  end
  
  #初始化节点的属性值
  def reset_task_item(part, repeat_time)
    part.attributes["repeat_time"] = "#{repeat_time}"
    part.attributes["status"] = "#{PLAN_STATUS[:UNFINISHED]}"
    part.each_element {|item|
      item.attributes["is_pass"] = "#{PLAN_STATUS[:UNFINISHED]}"
      item.attributes["repeat_time"] = "0"
      item.attributes["step"] = "0"
    }
  end
end
