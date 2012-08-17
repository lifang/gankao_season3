class LearnController < ApplicationController
  layout 'main'
  require 'rexml/document'
  include REXML

  respond_to :html, :xml, :json, :js

  def task_dispatch
    $category = params[:category] if $category.nil?
    $modulus = UserScoreInfo.where(["user_id = ? and category_id = ?", cookies[:user_id], $category]).first if $modulus.nil?
    if $items.nil? or $items.blank?
      return if (info = willdo_part_infos).nil?
      $type = info[:type].to_i
      $items = info[:ids]
    end
    p $items
    p $items[0]
    case $type
    when UserPlan::CHAPTER_TYPE_NUM[:WORD]
      @result = operate_word($items)
    when UserPlan::CHAPTER_TYPE_NUM[:SENTENCE]
      @result = operate_sentence($items)
    when UserPlan::CHAPTER_TYPE_NUM[:LINSTEN]
      @result = operate_hearing($items)
    end
  end
  
  #取出当前part的items 并组装 [id-repeat_time-step]
  def willdo_part_infos
    plan = UserPlan.where(["user_id = ? and category_id = ?", cookies[:user_id], $category]).first
    xml = REXML::Document.new(File.open(Constant::PUBLIC_PATH + plan.plan_url)) if plan
    xpath = "//plan//_#{xml.elements["//current"].text}[@status='#{UserPlan::PLAN_STATUS[:UNFINISHED]}']//part[@status='#{UserPlan::PLAN_STATUS[:UNFINISHED]}']"
    node = xml.elements[xpath]
    return nil unless !node.nil?
    return {:type => node.attributes["type"], :ids => node.elements.each("item[@is_pass='#{UserPlan::PLAN_STATUS[:UNFINISHED]}']"){}.inject(Array.new) { |arr, a| arr.push("#{a.attributes['id']}-#{a.attributes['repeat_time']}-#{a.attributes['step']}") } }
  end

  def operate_word(items)
    result = nil
    wid = items[0].split("-")[0]
    repeat = items[0].split("-")[1]
    step = items[0].split("-")[2].to_i + 1
    step = 3 if step > 3
    type = UserPlan::CHAPTER_TYPE_NUM[:WORD]
    word = Word.find(wid)
    if (step != 3)
      options = Word.get_words_by_level(word.level, word.category_id, 3, wid) << word
      result = {
        :type => type,
        :step => step,
        :repeat => repeat,
        :items => items,
        :time => Constant::WORD_TIME[step],
        :word => word,
        :options => options.sort_by { rand }
      }
    else
      result = {
        :type => type,
        :step => step,
        :repeat => repeat,
        :items => items,
        :time => Constant::WORD_TIME[step],
        :word => word,
        :sentence => WordSentence.find_all_by_word_id(wid).first.description.gsub(word.name,"_______")
      }
    end
   
    return result
  end

  def operate_sentence(items)
    result = nil
    id = items[0].split("-")[0]
    sentence = PracticeSentence.find(id)
    step = items[0].split("-")[2].to_i + 1
    step = 2 if step > 2
    words = sentence_words(sentence.en_mean)
    rtime = Constant::SENTENCE_TIME[:READ] * words.length
    rtime < Constant::SENTENCE_TIME[:RMIN] ? rtime = Constant::SENTENCE_TIME[:RMIN] : nil
    ctime = Constant::SENTENCE_TIME[:COMBIN] * words.length
    ctime < Constant::SENTENCE_TIME[:CMIN] ? ctime = Constant::SENTENCE_TIME[:CMIN] : nil
    rtime = ctime  if step == 2
    result = {
      :type => $type,
      :step => step,
      :words => words.sort_by { rand },
      :time => rtime,
      :combin_time =>ctime,
      :sentence => sentence
    }
    return result
  end

  def operate_hearing(items)
    result = nil
    id = items[0].split("-")[0]
    listen = PracticeSentence.find(id)
    words = sentence_words(listen.en_mean)
    time = words.length * Constant::LISTEN_TIME[:PER]
    time > Constant::LISTEN_TIME[:MAX] ? time = Constant::LISTEN_TIME[:MAX] : nil
    time < Constant::LISTEN_TIME[:MIN] ? time = Constant::LISTEN_TIME[:MIN] : nil
    options = PracticeSentence.get_listen_by_level(listen.level, listen.category_id, listen.types, 1, id) << listen
    result = {
      :type => $type,
      :time => time,
      :listen => listen,
      :options => options.sort_by { rand }
    }
    return result
  end

  def jude_word
    id = $items[0].split("-")[0].to_i
    repeat = $items[0].split("-")[1].to_i
    step = $items[0].split("-")[2].to_i  #当前要进行的步骤 1、2、3
    xpath = "//part[@type='#{$type}']//item[@id='#{id}']"
    elem = nil
    if params[:flag] == "true"
      if repeat == 0 or repeat == 1
        if step == 0 or step == 1
          elem = "#{id}-0-#{step+1}"
          rewrite_xml_item(xpath, nil, 0, step + 1)
        elsif step == 2
          elem = "#{id}-0-#{step+1}"
          rewrite_xml_item(xpath, UserPlan::PLAN_STATUS[:FINISHED], 0, step + 1)
        end
      elsif repeat == 2
        elem = "#{id}-1-#{step}"
        rewrite_xml_item(xpath, nil, 1, step)
      end
    end
    if params[:flag] == "false"
      elem = "#{id}-2-#{step}"
      rewrite_xml_item(xpath, nil, 2, nil)
    end
    if (step == 2 && repeat <= 1 && params[:flag] == "true")
      $items = ($items - [$items[0]])
    else
      $items = ($items - [$items[0]]).push(elem)
    end
    pass_status("part") if $items.blank?
    @redirct = params[:redirct]
  end

  def jude_sentence
    id = $items[0].split("-")[0].to_i
    step = $items[0].split("-")[2].to_i  #当前要进行的步骤 1、2
    xpath = "//part[@type='#{$type}']//item[@id='#{id}']"
    if params[:flag] == "true"
      if step == 2
        $items = ($items - [$items[0]])
        rewrite_xml_item(xpath, UserPlan::PLAN_STATUS[:FINISHED], nil, nil)
      else
        $items = ($items - [$items[0]]).push("#{id}-0-#{step+1}")
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
    id = $items[0].split("-")[0].to_i
    xpath = "//part[@type='#{$type}']//item[@id='#{id}']"
    if params[:flag] == "true"
      rewrite_xml_item(xpath, UserPlan::PLAN_STATUS[:FINISHED], nil, nil)
      $items = ($items - [$items[0]])
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
    id = $items[0].split("-")[0].to_i
    type = UserPlan::CHAPTER_TYPE_NUM[:WORD]
    xpath = "//part[@type='#{type}']//item[@id='#{id}']"
    rewrite_xml_item(xpath, UserPlan::PLAN_STATUS[:FINISHED], nil, nil)
    $items = ($items - [$items[0]])
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
    #题目类型 0 为单词，5为听写
    part_type='0'
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
