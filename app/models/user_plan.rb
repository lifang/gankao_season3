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
    :TRANSLATE => "translate", :DICTATION => "dictation", :WRITE => "write"}#单词、句子、听力、阅读、翻译、听写、写作
  CHAPTER = {:cha1 => "基础", :cha2 => "综合", :cha3 => "冲刺"} #三个阶段的名称
  CHAPTER_TYPE_NUM = {:WORD => 0, :SENTENCE => 1, :LINSTEN => 2, :READ => 3,
    :TRANSLATE => 4, :DICTATION => 5, :WRITE => 6}#单词、句子、听力、阅读、翻译、听写、写作

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
  def self.calculate_user_plan_info(uid, category_id, target_score)
    user = UserScoreInfo.where(["user_id = ? and category_id = ?", uid, category_id]).first
    return if user.nil?
    return nil unless target_level_hash = target_level_report(target_score, category_id)
    s_word = user.all_start_level.split(",")[0].to_i*PER_ITEMS[:WORD]
    s_sentence = user.all_start_level.split(",")[1].to_i*PER_ITEMS[:SENTENCE]
    s_listen = user.all_start_level.split(",")[2].to_i*PER_ITEMS[:LISTEN]
    word_num = target_level_hash[:WORD]*PER_ITEMS[:WORD] - s_word
    sentence_num = target_level_hash[:SENTENCE]*PER_ITEMS[:SENTENCE] - s_sentence
    read_num = target_level_hash[:READ]*PER_ITEMS[:READ]
    write_num = target_level_hash[:WRITE]*PER_ITEMS[:WRITE]
    if category_id == (Category::TYPE[:CET4] || Category::TYPE[:CET6])
      listen_num = target_level_hash[:LISTEN]*PER_ITEMS[:LISTEN] - s_listen
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
    if result[:ALL] <= left_mis
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
    if category_id == (Category::TYPE[:CET4] || Category::TYPE[:CET6])
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
    sys_provide_score_report(s_word, s_sentence, s_listen, result,category_id)
    return result
  end

  #根据计划计算 预计分数
  def UserPlan.sys_provide_score_report(s_word, s_sentence, s_listen, user_plan,category_id)
    if category_id == (Category::TYPE[:CET4] || Category::TYPE[:CET6])
      score = sys_provide_score((user_plan[:WORD] + s_word).to_f/PER_ITEMS[:WORD], Word::MAX_LEVEL[:"#{Category::FLAG[category_id]}"], category_id, 0.15)
      score += sys_provide_score((user_plan[:SENTENCE] + s_sentence).to_f/PER_ITEMS[:SENTENCE], PracticeSentence::SENTENCE_MAX_LEVEL[:"#{Category::FLAG[category_id]}"], category_id, 0.2)
      score += sys_provide_score((user_plan[:LISTEN] + s_listen).to_f/PER_ITEMS[:LISTEN], PracticeSentence::LISTEN_MAX_LEVEL[:"#{Category::FLAG[category_id]}"], category_id, 0.15)
      score += sys_provide_score(user_plan[:TRANSLATE].to_f/PER_ITEMS[:TRANSLATE], PracticeSentence::TRANSLATE_MAX_LEVEL[:"#{Category::FLAG[category_id]}"], category_id, 0.2)
      score += sys_provide_score(user_plan[:DICTATION].to_f/PER_ITEMS[:DICTATION], PracticeSentence::DICTATION_MAX_LEVEL[:"#{Category::FLAG[category_id]}"], category_id, 0.1)
      score += sys_provide_score(user_plan[:READ].to_f/PER_ITEMS[:READ], Tractate::READ_MAX_LEVEL[:"#{Category::FLAG[category_id]}"], category_id, 0.05)
      score += sys_provide_score(user_plan[:WRITE].to_f/PER_ITEMS[:WRITE], Tractate::WRITE_MAX_LEVEL[:"#{Category::FLAG[category_id]}"], category_id, 0.1)
      score += Examination::MAX_SCORE[:"#{Category::FLAG[category_id]}"]*0.05
    else
      score = sys_provide_score((user_plan[:WORD] + s_word).to_f/PER_ITEMS[:WORD], Word::MAX_LEVEL[:"#{Category::FLAG[category_id]}"], category_id, 0.2)
      score += sys_provide_score((user_plan[:SENTENCE] + s_sentence).to_f/PER_ITEMS[:SENTENCE], PracticeSentence::SENTENCE_MAX_LEVEL[:"#{Category::FLAG[category_id]}"], category_id, 0.25)
      score += sys_provide_score(user_plan[:READ].to_f/PER_ITEMS[:READ], Tractate::READ_MAX_LEVEL[:"#{Category::FLAG[category_id]}"], category_id, 0.3)
      score += sys_provide_score(user_plan[:WRITE].to_f/PER_ITEMS[:WRITE], Tractate::WRITE_MAX_LEVEL[:"#{Category::FLAG[category_id]}"], category_id, 0.15)
      score += Examination::MAX_SCORE[:"#{Category::FLAG[category_id]}"]*0.1
    end
  end

  #根据计划计算 每一项所占的预计分数
  def UserPlan.sys_provide_score(target_level, max_level, category_id, score_precent)
    category = Category::FLAG[category_id]
    max_score = Examination::MAX_SCORE[:"#{category}"]
    y = max_level%2 == 0 ? max_level + 1 : max_level # 41
    x = (y-1)*0.5  # 20
    total_area = max_level%2 == 0 ? x*y-y/x*0.5 : x*y
    if target_level*2 > max_level
      #在正轴
      return max_score*score_precent*(total_area - ((0.5*total_area*(max_level-target_level))/x))/total_area
    else
      return max_score*score_precent*((0.5*total_area*target_level)/x)/total_area
    end
  end
  
  #确定计划的天数(即：包的数量)
  #根据不同科目 下给定的区间值选择最优值
  def UserPlan.package_level(category_id)
    today = Time.now.strftime("%Y-%m-%d")
    day = (Constant::DEAD_LINE[:"#{Category::FLAG[category_id]}"].to_time - today.to_time)/86400
    if category_id == (Category::TYPE[:CET4] || Category::TYPE[:CET6])
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

  def plan_list
    file=File.open "#{Constant::PUBLIC_PATH}#{self.paper_url}"
    doc = Document.new(file)
    file.close
    return doc
  end

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

  #生成初始计划
  def self.init_plan(user_score_info, data_info, user_id, category_id)
    user_plan = UserPlan.create(:category_id => category_id, :user_id => user_id, :days => data_info[:DAYS])
    #chapter = self.return_chapter_data(data_info)
    user_plan.create_plan_url(self.xml_content(user_score_info.get_start_level, return_chapter_data(data_info)),
      category_id.to_s + "_" + user_plan.id.to_s)
    return user_plan
  end


  def create_plan_url(str, path, super_path = "plan_xmls")
    file_name = self.write_file(str, path, super_path)
    self.plan_url = "/"+super_path + file_name
    self.save
  end

  #返回各个部分的时间
  def return_chapter_data(data_info)
    first_chapter = ((data_info[:ONE].to_f/data_info[:ALL].to_i)*data_info[:DAYS]).ceil
    second_chapter = ((data_info[:TWO].to_f/data_info[:ALL].to_i)*data_info[:DAYS]).ceil
    third_chapter = data_info[:DAYS] - first_chapter - second_chapter
    word_avg = (data_info[:WORD].to_f/first_chapter).ceil
    sentence_avg = (data_info[:SENTENCE].to_f/first_chapter).ceil
    listen_avg = (data_info[:LISTEN].to_f/first_chapter).ceil
    read_avg = (data_info[:READ].to_f/second_chapter).ceil
    translate_avg = (data_info[:TRANSLATE].to_f/second_chapter).ceil
    dictation_avg = (data_info[:DICTATION].to_f/second_chapter).ceil
    write_avg = (data_info[:WRITE].to_f/third_chapter).ceil
    similarity_avg = PAPER_NUM/third_chapter
    return { :first_chapter => first_chapter, :second_chapter => second_chapter, :third_chapter => third_chapter,
      :word_avg => word_avg, :sentence_avg => sentence_avg, :listen_avg => listen_avg, :read_avg => read_avg,
      :translate_avg => translate_avg, :dictation_avg => dictation_avg, :write_avg => write_avg,
      :similarity_avg => similarity_avg }
  end

  #创建xml文件 tiku_hash = get_start_level, chapter_info = return_chapter_data
  def xml_content(tiku_hash, chapter_info)
    task_info = self.return_task(tiku_hash, chapter_info)
    content = "<?xml version='1.0' encoding='UTF-8'?>"
    content += <<-XML
      <root>
        <plan>
            <current>1</current>
            <info>
                <chapter1 word='#{chapter_info[:word_avg]}' sentence='#{chapter_info[:sentence_avg]}' linsten='#{chapter_info[:listen_avg]}' days='#{chapter_info[:first_chapter]}' />
                <chapter2 read='#{chapter_info[:read_avg]}' translate='#{chapter_info[:translate_avg]}' dictation='#{chapter_info[:dictation_avg]}' days='#{chapter_info[:second_chapter]}' />
                <chapter3 write='#{chapter_info[:write_avg]}' similarity='#{chapter_info[:similarity_avg]}'  days='#{chapter_info[:third_chapter]}' />
            </info>
            <_1 status='0'>
              <part type='#{CHAPTER_TYPE_NUM[:WORD]}' status='0'>#{task_info[:word_info]}</part>
              <part type='#{CHAPTER_TYPE_NUM[:SENTENCE]}' status='0'>#{task_info[:sentence_info]}</part>
              <part type='#{CHAPTER_TYPE_NUM[:LINSTEN]}' status='0'>#{task_info[:listen_info]}</part>
            </_1>
    XML
    (2..chapter_info[:first_chapter].to_i).each {|i|
      content += <<-XML
        <_#{i} stauts='0'>
          <part type='#{CHAPTER_TYPE_NUM[:WORD]}' num='#{chapter_info[:word_avg]}'/>
          <part type='#{CHAPTER_TYPE_NUM[:SENTENCE]}' num='#{chapter_info[:sentence_avg]}'/>
          <part type='#{CHAPTER_TYPE_NUM[:LINSTEN]}' num='#{chapter_info[:listen_avg]}'/>
        </_#{i}>
      XML
    }
    ((chapter_info[:first_chapter].to_i+1)..(chapter_info[:second_chapter].to_i)).each{|i|
      content += <<-XML
        <_#{i} stauts='0'>
          <part type='#{CHAPTER_TYPE_NUM[:READ]}' num='#{chapter_info[:read_avg]}'/>
          <part type='#{CHAPTER_TYPE_NUM[:TRANSLATE]}' num='#{chapter_info[:translate_avg]}'/>
          <part type='#{CHAPTER_TYPE_NUM[:DICTATION]}' num='#{chapter_info[:dictation_avg]}'/>
        </_#{i}>
      XML
    }
    ((chapter_info[:second_chapter].to_i+1)..(chapter_info[:third_chapter].to_i)).each{|i|
      content += <<-XML
        <_#{i} stauts='0'>
          <part type='#{CHAPTER_TYPE_NUM[:WRITE]}' num='#{chapter_info[:write_avg]}'/>
          <part type='#{CHAPTER_TYPE_NUM[:WRITE]}' num='#{chapter_info[:similarity_avg]}'/>
        </_#{i}>
      XML
    }
    content += <<-XML
        </plan>
        <tiku>
          <part type='#{CHAPTER_TYPE_NUM[:WORD]}' lv='#{tiku_hash[:levels][0]}' item='#{task_info[:leave_word].join(",")}'/>
          <part type='#{CHAPTER_TYPE_NUM[:SENTENCE]}' lv='#{tiku_hash[:levels][1]}' item='#{task_info[:leave_sentence].join(",")}'/>
          <part type='#{CHAPTER_TYPE_NUM[:LINSTEN]}' lv='#{tiku_hash[:levels][2]}' item='#{task_info[:leave_listen].join(",")}'/>
        </tiku>
      </root>
    XML
    return content
  end
  
  #返回默认第一个任务，以及剩下的题库的单词 tiku_hash = get_start_level, chapter_info = return_chapter_data
  def return_task(tiku_hash, chapter_info)
    word_list = proof_code(tiku_hash[:word], chapter_info[:word_avg])
    sentence_list = proof_code(tiku_hash[:practice_sentences], chapter_info[:sentence_avg])
    listen_list = proof_code(tiku_hash[:listens], chapter_info[:listen_avg])
    word_info, sentence_info, listen_info = ""
    word_list.each { |w| word_info += "<item id='#{w}' is_pass='false' repeat_time='0' step='0' />" }
    sentence_list.each { |s| sentence_info += "<item id='#{s}' is_pass='false' repeat_time='0' step='0' />" }
    listen_list.each { |l| listen_info += "<item id='#{l}' is_pass='false' repeat_time='0' step='0' />" }
    return {:word_info => word_info, :sentence_info => sentence_info, :listen_info => listen_info,
      :leave_word => tiku_hash[:word] - word_list, :leave_sentence  => tiku_hash[:practice_sentences] - sentence_list,
      :leave_listen => tiku_hash[:listens] - listen_list}
  end
  
  #写文件
  def write_file(str, path, super_path)
    dir = "#{Rails.root}/public/#{super_path}"
    Dir.mkdir(dir) unless File.directory?(dir)
    unless File.directory?(dir + "/" + Time.now.strftime("%Y-%m"))
      Dir.mkdir(dir + "/" + Time.now.strftime("%Y-%m"))
    end
    file_name = "/" + Time.now.strftime("%Y-%m") + path
    url = dir + file_name
    f=File.new(url,"w+")
    f.write("#{str.force_encoding('UTF-8')}")
    f.close
    return "/#{super_path}" + file_name
  end


end
