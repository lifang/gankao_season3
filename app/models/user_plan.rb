# encoding: utf-8
class UserPlan < ActiveRecord::Base
  belongs_to :category
  belongs_to :user

  require 'rexml/document'
  include REXML
  
  CHAPTER_TYPE = {:WORD => "word", :SENTENCE => "sentence", :LINSTEN => "linsten", :READ => "read",
    :TRANSLATE => "translate", :DICTATION => "dictation", :WRITE => "write"}#单词、句子、听力、阅读、翻译、听写、写作
  CHAPTER = {:cha1 => "基础", :cha2 => "综合", :cha3 => "冲刺"} #三个阶段的名称
  CHAPTER_TYPE_NUM = {:WORD => 0, :SENTENCE => 1, :LINSTEN => 2, :READ => 3,
    :TRANSLATE => 4, :DICTATION => 5, :WRITE => 6}#单词、句子、听力、阅读、翻译、听写、写作

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

  #确定计划的天数
  def self.package_level(category)
    today = Time.now.strftime("%Y-%m-%d")
    day = (Constant::DEAD_LINE[:"#{category}"].to_time - today.to_time)/86400
    if category == ("CET4" || "CET6")
      CET46_PLANS.each { |k,v|
        return v if v > day
      }
    elsif category == "GRADUATE"
      GRADUATE_PLANS.each { |k,v|
        return v if v > day
      }
    end
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
  def self.init_plan(task_hash, time_hash, user_id, category_id)
    user_score_info = UserScoreInfo.find_by_category_id_and_user_id(category_id, user_id)

    user_plan = UserPlan.create(:category_id => category_id, :user_id => user_id)
    
  end

  def create_plan_url(str, path, super_path = "plan_xmls")
    file_name = self.write_file(str, path, super_path)
    self.plan_url = "/"+super_path + file_name
    self.save
  end

  #取到默认开始的词库、句子跟听力
  def get_start_level(user_score_info)
    all_start_level =  user_score_info.all_start_level.split(",")
    words = Word.find(:select => "id", :conditions => ["category_id = ? and level = ?",
        user_score_info.category_id, all_start_level[0]])
    word_list = words.collect { |w| w.id }
    practice_sentences = PracticeSentence.find(:select => "id",
      :conditions => ["category_id = ? and types = ? and level = ?",
        user_score_info.category_id, PracticeSentence::TYPES[:SENTENCE], all_start_level[1]])
    sentence_list = practice_sentences.collect { |s| s.id }
    listens = PracticeSentence.find(:select => "id",
      :conditions => ["category_id = ? and types = ? and level = ?",
        user_score_info.category_id, PracticeSentence::TYPES[:LINSTEN], all_start_level[2]])
    listen_list = listens.collect { |l| l.id }
    return {:word => word_list, :practice_sentences => sentence_list, :listens => listen_list, :levels => all_start_level}
  end

  #返回各个部分的时间
  def return_chapter_data(data_info)
    first_chapter = ((data_info[:ONE].to_f/data_info[:ALL].to_i)*data_info[:DAYS]).ceil
    second_chapter = ((data_info[:TWO].to_f/data_info[:ALL].to_i)*data_info[:DAYS]).ceil
    third_chapter = data_info[:DAYS] - first_chapter - second_chapter
    word_avg = data_info[:WORD]/first_chapter
    sentence_avg = data_info[:SENTENCE]/first_chapter
    listen_avg = data_info[:LISTEN]/first_chapter
    
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

  #创建xml文件
  def xml_content(tiku_hash, data_info)
    
    content = "<?xml version='1.0' encoding='UTF-8'?>"
    content += <<-XML
      <root>
        <plan>
            <current>1</current>
            <info>
                <chapter1 word='#{sd}' sentence='6' linsten='5' days='22' />
                <chapter2 read='5' translate='5' dictation='3' days='24' />
                <chapter3 write='1' days='23' />
            </info>
        </plan>
    XML

    content += <<-XML
        <tiku>
          <part type='#{CHAPTER_TYPE_NUM[:WORD]}' lv='#{tiku_hash[:levels][0]}' item='#{tiku_hash[:word].join(",")}'/>
          <part type='#{CHAPTER_TYPE_NUM[:SENTENCE]}' lv='#{tiku_hash[:levels][1]}' item='#{tiku_hash[:practice_sentences].join(",")}'/>
          <part type='#{CHAPTER_TYPE_NUM[:LINSTEN]}' lv='#{tiku_hash[:levels][2]}' item='#{tiku_hash[:listens].join(",")}'/>
        </tiku>
      </root>
    XML
    return content
  end
  
  
  



end
