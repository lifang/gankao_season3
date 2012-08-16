class LearnController < ApplicationController
  layout 'main'
  require 'rexml/document'
  include REXML

  respond_to :html, :xml, :json, :js

  def task_dispatch
    if $items.nil? or $items.blank?
      info = willdo_part_infos
      $type = info[:type].to_i
      $items = info[:ids] # id-repeat_time-step
    end
    p $items
    case $type
    when UserPlan::CHAPTER_TYPE_NUM[:WORD]
      @result = operate_word($items)
    when UserPlan::CHAPTER_TYPE_NUM[:SENTENCE]
      @result = operate_sentence($items)
    end
  end

  def jude_word
    id = $current_item.split("-")[0].to_i
    repeat = $current_item.split("-")[1].to_i
    step = $current_item.split("-")[2].to_i  #当前要进行的步骤 1、2、3
    xpath = "//part[@type='#{$type}']//item[@id='#{id}']"
    elem = nil
    if params[:flag] == "true"
      if step == 3 && repeat == 0
        elem = "#{id}-#{repeat}-#{step}"
        rewrite_xml_item(xpath, "true", nil, nil)
      elsif step != 3 && repeat == 0
        elem = "#{id}-#{repeat}-#{step + 1}"
        rewrite_xml_item(xpath, nil, nil, step + 1)
      elsif repeat != 0
        elem = "#{id}-#{repeat-1}-#{step}"
        rewrite_xml_item(xpath, nil, repeat - 1, nil)
        if repeat == 1 && step != 3
          elem = "#{id}-#{repeat - 1}-#{step + 1}"
          rewrite_xml_item(xpath, nil, nil, step + 1)
        elsif repeat == 1 && step == 3
          elem = "#{id}-#{repeat}-#{step}"
          rewrite_xml_item(xpath, "true", nil, nil)
        end
      end
    else
      elem = "#{id}-#{2}-#{step}"
      rewrite_xml_item(xpath, nil, 2, nil)
    end
    if ((step == 3 && repeat == 0) || (step == 3 && repeat == 1 && params[:flag] == "true") )
      $items = ($items - [$current_item])
    else
      $items = ($items - [$current_item]).push(elem)
    end
    if $items.blank?
      pass_status("part")
    end
    @redirct = params[:redirct]
  end

  def jude_sentence
    
  end

  def i_have_remember
    id = $current_item.split("-")[0].to_i
    type = UserPlan::CHAPTER_TYPE_NUM[:WORD]
    xpath = "//part[@type='#{type}']//item[@id='#{id}']"
    rewrite_xml_item(xpath, "true", nil, nil)
    $items = ($items - [$current_item])
    @redirct = "true"
  end
  
  def rewrite_xml_item(xpath, is_pass, repeat_time, step)
    plan = UserPlan.where(["user_id = ? and category_id = ?", cookies[:user_id], 2]).first
    xml = REXML::Document.new(File.open(Constant::PUBLIC_PATH + plan.plan_url)) if plan
    element = xml.elements["//plan//_#{xml.elements['//current'].text}"+xpath]
    element.add_attribute("is_pass", "true") if is_pass == "true"
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
  
  def operate_word(items)
    result = nil
    $current_item = items[0]
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
    $current_item = items[0]
    p $current_item
    id = $current_item.split("-")[0]
    sentence = PracticeSentence.find(id)
    step = $current_item.split("-")[2].to_i + 1
    words = sentence_words(sentence.en_mean)
    result = {
      :type => $type,
      :step => step,
      :words => words,
      :time => Constant::SENTENCE_TIME[:READ] * words.length,
      :combin_time => Constant::SENTENCE_TIME[:COMBIN] * words.length,
      :sentence => sentence
    }
    return result
  end

  def sentence_words(str)
    return str.gsub(/"/," ").gsub(/:/," ").gsub(/;/," ").gsub(/\?/," ").gsub(/!/," ").gsub(/,/," ").gsub(/\./," ").gsub(/  /," ").split(" ").sort_by { rand }
  end

  def willdo_part_infos
    plan = UserPlan.where(["user_id = ? and category_id = ?", cookies[:user_id], 2]).first
    xml = REXML::Document.new(File.open(Constant::PUBLIC_PATH + plan.plan_url)) if plan
    xpath = "//plan//_#{xml.elements["//current"].text}[@status='#{UserPlan::PLAN_STATUS[:UNFINISHED]}']//part[@status='#{UserPlan::PLAN_STATUS[:UNFINISHED]}']"
    node = xml.elements[xpath]
    return nil unless !node.nil?
    return {:type => node.attributes["type"], :ids => node.elements.each("item[@is_pass='false']"){}.inject(Array.new) { |arr, a| arr.push("#{a.attributes['id']}-#{a.attributes['repeat_time']}-#{a.attributes['step']}") } }
  end

  
  def listen
    #获取用户信息和xml路径和类别
    #  获取听写数据
    #    @source=listen_write_source(xml)
    #
    #    if @source.nil?
    #      redirect_to ''
    #    end
    #    @listen_sentence=@source[:listen_sentence]
    #    @web_type=@source[:web_type]
    #    @step=@source[:step]
    ids=[2,4,5,7,8,9,12,18,20,22,24]
    @index=0
    @listen_sentence=PracticeSentence.find(ids[index])
    @web_type="review"
    @step=2
    @num=ids.length
    @source={:listen_sentence=>@listen_sentence,:web_type=>@web_type,:step=>@step,:num=>@num}
  end
  def next_sentence
    type = params[:type]
    sentence_id = params[:id]
    is_correct=params[:is_correct]
    #    #获取用户xml路径
    #    x_url = "#{Rails.root}/public/2.xml"
    #    xml =Document.new(File.open(x_url))
    #
    #    if type="plan"
    #      #处理新学的句子
    #    elsif type="review"
    #      #处理复习的句子
    #    end
    #
    #    #写入xml
    #    #获取新数据
    #    source=listen_write_source(xml)
    sentence_id=sentence_id.to_i+1
    @listen_sentence=PracticeSentence.find(sentence_id)
 
    @web_type="review"
    @step=2
    @num=30
    source={:listen_sentence=>@listen_sentence,:web_type=>@web_type,:step=>@step,:num=>@num}
    render :partial=>'/learn/listen_write',:object=>source

  end
end
