class LearnController < ApplicationController
  layout 'main'
  require 'rexml/document'
  include REXML

  respond_to :html, :xml, :json, :js

  def task_dispatch
    $category = params[:category] if $category.nil?
    $modulus = UserScoreInfo.where(["user_id = ? and category_id = ?", cookies[:user_id], $category]).first.modulus || 1 if $modulus.nil?
    if $items.nil? or $items.blank?
      return if (info = willdo_part_infos($category)).nil?
      $type = info[:type].to_i
      $items = info[:ids]
      $ids = $items.inject(Array.new) { |arr,item| arr.push(item.split("-")[0]) }
    end
    
    $current_id = $items[0].split("-")[0] if $items[0]
    case $type
    when UserPlan::CHAPTER_TYPE_NUM[:WORD]
      @result = operate_word($items)
    when UserPlan::CHAPTER_TYPE_NUM[:SENTENCE]
      @result = operate_sentence($items)
    when UserPlan::CHAPTER_TYPE_NUM[:LINSTEN]
      @result = operate_hearing
    end
  end
  
  #取出当前part的items 并组装 [id-repeat_time-step]
  def willdo_part_infos(category)
    plan = UserPlan.where(["user_id = ? and category_id = ?", cookies[:user_id], category]).first
    xml = REXML::Document.new(File.open(Constant::PUBLIC_PATH + plan.plan_url)) if plan
    xpath = "//plan//_#{xml.elements["//current"].text}[@status='#{UserPlan::PLAN_STATUS[:UNFINISHED]}']//part[@status='#{UserPlan::PLAN_STATUS[:UNFINISHED]}']"
    node = xml.elements[xpath]
     p node.elements.each("item[@is_pass='#{UserPlan::PLAN_STATUS[:UNFINISHED]}']"){}
    return nil unless !node.nil?
    return {:type => node.attributes["type"], :ids => node.elements.each("item[@is_pass='#{UserPlan::PLAN_STATUS[:UNFINISHED]}']"){}.inject(Array.new) { |arr, a| arr.push("#{a.attributes['id']}-#{a.attributes['repeat_time']}-#{a.attributes['step']}") } }
  end

  def operate_word(items)
    result = nil
    repeat = items[0].split("-")[1]
    step = items[0].split("-")[2].to_i + 1
    step = 3 if step > 3
    type = UserPlan::CHAPTER_TYPE_NUM[:WORD]
    word = Word.find($current_id)
    if (step != 3)
      options = Word.get_words_by_level(word.level, word.category_id, 3, $current_id) << word
      result = {
        :type => type,
        :step => step,
        :repeat => repeat,
        :items => items,
        :time => (Constant::WORD_TIME[step] * $modulus).to_i,
        :word => word,
        :options => options.sort_by { rand }
      }
    else
      result = {
        :type => type,
        :step => step,
        :repeat => repeat,
        :items => items,
        :time => (Constant::WORD_TIME[step] * $modulus).to_i,
        :word => word,
        :sentence => WordSentence.find_all_by_word_id($current_id).first.description.gsub(word.name,"_______")
      }
    end
   
    return result
  end

  def operate_sentence(items)
    result = nil
    sentence = PracticeSentence.find($current_id)
    step = items[0].split("-")[2].to_i + 1
    step = 2 if step > 2
    words = sentence_words(sentence.en_mean)
    rtime = Constant::SENTENCE_TIME[:READ] * words.length  * $modulus
    ctime = Constant::SENTENCE_TIME[:COMBIN] * words.length  * $modulus
    rtime = ctime  if step == 2
    result = {
      :type => $type,
      :step => step,
      :words => words.sort_by { rand },
      :time => rtime.to_i,
      :combin_time =>ctime.to_i,
      :sentence => sentence
    }
    return result
  end

  def operate_hearing
    result = nil
    listen = PracticeSentence.find($current_id)
    words = sentence_words(listen.en_mean)
    time = words.length * Constant::LISTEN_TIME[:PER] * $modulus
    options = PracticeSentence.get_listen_by_level(listen.level, listen.category_id, listen.types, 1, $current_id) << listen
    result = {
      :type => $type,
      :time => time.to_i,
      :listen => listen,
      :options => options.sort_by { rand }
    }
    return result
  end

  def jude_word
    repeat = $items[0].split("-")[1].to_i
    step = $items[0].split("-")[2].to_i  #当前要进行的步骤 1、2、3
    xpath = "//part[@type='#{$type}']//item[@id='#{$current_id}']"
    elem = nil
    if params[:flag] == "true"
      if repeat == 0 or repeat == 1
        if step == 0 or step == 1
          elem = "#{$current_id}-0-#{step+1}"
          rewrite_xml_item(xpath, nil, 0, step + 1)
        elsif step == 2
          elem = "#{$current_id}-0-#{step+1}"
          rewrite_xml_item(xpath, UserPlan::PLAN_STATUS[:FINISHED], 0, step + 1)
        end
      elsif repeat == 2
        elem = "#{$current_id}-1-#{step}"
        rewrite_xml_item(xpath, nil, 1, step)
      end
    end
    if params[:flag] == "false"
      elem = "#{$current_id}-2-#{step}"
      rewrite_xml_item(xpath, nil, 2, nil)
    end
    if (step == 2 && repeat <= 1 && params[:flag] == "true")
      $ids = $ids - [$items[0].split("-")[0]]
      $items = $items - [$items[0]]
    else
      $items = ($items - [$items[0]]).push(elem)
    end
    pass_status("part") if $items.blank?
    @redirct = params[:redirct]
  end

  def jude_sentence
    step = $items[0].split("-")[2].to_i  #当前要进行的步骤 1、2
    xpath = "//part[@type='#{$type}']//item[@id='#{$current_id}']"
    if params[:flag] == "true"
      if step == 1
        $ids = $ids - [$items[0].split("-")[0]]
        $items = $items - [$items[0]]
        rewrite_xml_item(xpath, UserPlan::PLAN_STATUS[:FINISHED], nil, nil)
      else
        $items = ($items - [$items[0]]).push("#{$current_id}-0-#{step+1}")
        rewrite_xml_item(xpath, nil, nil, step + 1)
      end
    else
      $items = ($items - [$items[0]]).push($items[0])
    end
    if $items.blank?
      pass_status("part")
    end
    @redirct = params[:redirct]
  end

  def jude_hearing
    xpath = "//part[@type='#{$type}']//item[@id='#{$current_id}']"
    if params[:flag] == "true"
      rewrite_xml_item(xpath, UserPlan::PLAN_STATUS[:FINISHED], nil, nil)
      $ids = $ids - [$items[0].split("-")[0]]
      $items = $items - [$items[0]]
    else
      $items = ($items - [$items[0]]).push($items[0])
    end
    if $items.blank?
      pass_status("part")
      pass_status("all")
      UserPlan.where(["user_id = ? and category_id = ?", cookies[:user_id], $category]).first.update_plan
    end
    @redirct = params[:redirct]
  end

  def i_have_remember
    type = UserPlan::CHAPTER_TYPE_NUM[:WORD]
    xpath = "//part[@type='#{type}']//item[@id='#{$current_id}']"
    rewrite_xml_item(xpath, UserPlan::PLAN_STATUS[:FINISHED], nil, nil)
    $ids = $ids - [$current_id]
    $items = $items - [$items[0]]
    pass_status("part") if $items.blank?
    p $items
    @redirct = "true"
  end
  
  def rewrite_xml_item(xpath, is_pass, repeat_time, step)
    plan = UserPlan.where(["user_id = ? and category_id = ?", cookies[:user_id], 2]).first
    xml = REXML::Document.new(File.open(Constant::PUBLIC_PATH + plan.plan_url)) if plan
    element = xml.elements["//plan//_#{xml.elements['//current'].text}"+xpath]
    element.add_attribute("is_pass", UserPlan::PLAN_STATUS[:FINISHED]) if is_pass == UserPlan::PLAN_STATUS[:FINISHED]
    element.add_attribute("repeat_time", repeat_time) if repeat_time
    element.add_attribute("step", step) if step
    f = File.new(Constant::PUBLIC_PATH + plan.plan_url,"w+")
    f.write("#{xml.to_s.force_encoding('UTF-8')}")
    f.close
  end

  def pass_status(kind) #kind = 部分 or 整个包
    plan = UserPlan.where(["user_id = ? and category_id = ?", cookies[:user_id], 2]).first
    xml = REXML::Document.new(File.open(Constant::PUBLIC_PATH + plan.plan_url)) if plan
    if kind == "part"
      element = xml.elements["//plan//_#{xml.elements['//current'].text}//part[@type=#{$type}]"]
    else
      element = xml.elements["//plan//_#{xml.elements['//current'].text}"]
    end
    element.add_attribute("status", UserPlan::PLAN_STATUS[:FINISHED])
    f = File.new(Constant::PUBLIC_PATH + plan.plan_url,"w+")
    f.write("#{xml.to_s.force_encoding('UTF-8')}")
    f.close
  end

  def study_it
    @result = nil
    if $type == UserPlan::CHAPTER_TYPE_NUM[:WORD]
      @result = {
        :word => Word.find($current_id),
        :sentences => WordSentence.find_all_by_word_id($current_id)
      }
    elsif $type == UserPlan::CHAPTER_TYPE_NUM[:SENTENCE]
      @result = {
        :sentence => WordSentence.find($current_id)
      }
    elsif $type == UserPlan::CHAPTER_TYPE_NUM[:LINSTEN]
      @result = {
        :sentence => PracticeSentence.find($current_id)
      }
    end
  end

 
  def sentence_words(str)
    return str.gsub(/"/," ").gsub(/:/," ").gsub(/;/," ").gsub(/\?/," ").gsub(/!/," ").gsub(/,/," ").gsub(/\./," ").gsub(/  /," ").split(" ")
  end

  def listen
    #获取用户信息和xml路径和类别
    x_url = "#{Rails.root}/public/plan_xmls/2012-08/2_19.xml"
    xml =Document.new(File.open(x_url))
    #  获取听写数据
    @source=listen_write_source(xml)
    if @source.nil?
      render :text=>"今天题目已经答完"
    end
  end
  def next_sentence
    type = params[:type]
    id = params[:id]
    is_correct=params[:is_correct]
    is_answer=params[:is_answer]
    index=params[:index].to_i
    #题目类型  5为听写
    part_type=UserPlan::CHAPTER_TYPE_NUM[:DICTATION].to_s
    #获取用户xml路径
    x_url = "#{Rails.root}/public/plan_xmls/2012-08/2_19.xml"
    xml =Document.new(File.open(x_url))
    current=xml.elements["root/plan/current"].text.to_i
    #处理句子更改状态,根据类型不同进行不同的操作
    if is_answer=='true'
      xml_and_index=handle_sentences(xml,current,type,id,is_correct,index,part_type)
      xml=xml_and_index[:xml]
      #写入xml
      write_xml(xml,x_url)
      index=xml_and_index[:index]
    end
 
    if !($ids.empty?)
      index=index<$ids.length-1?index+1:0
      next_id=$ids[index]
      #获取新数据
      source=listen_write_by_id(xml,type,current,next_id,part_type)
      source[:index]=index
      render :partial=>'/learn/listen_write',:object=>source
    else
      #更改当前句子部分的status的值 type为plan或review current为当前包
      change_part_status(xml,type,current,part_type)
      write_xml(xml,x_url)
      #继续查找句子数据,如果没有 表示今天句子任务已经完成
      listen_source=listen_write_source(xml)
      if !(listen_source.nil?)
        render :partial=>'/learn/listen_write',:object=>listen_source
      else
        render :text=>"答题完成"
      end
    end
  end
end
