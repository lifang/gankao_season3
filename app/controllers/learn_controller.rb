class LearnController < ApplicationController
  layout nil
  require 'rexml/document'
  include REXML

  respond_to :html, :xml, :json, :js

  def task_dispatch
    if cookies[:type].nil? or cookies[:items].nil?
      info = willdo_part_infos
      cookies[:type]={:value =>info[:type], :path => "/", :secure  => false}
      cookies[:items]={:value =>info[:ids], :path => "/", :secure  => false} # id-repeat_time-step
    end
    case cookies[:type].to_i
    when UserPlan::CHAPTER_TYPE_NUM[:WORD]
      @result = operate_word(cookies[:items])
    when UserPlan::CHAPTER_TYPE_NUM[:SENTENCE]
      p "senetence"
    end
  end

  def jude_word
    type = params[:type]
    id = params[:id]
    step = params[:step]
    repeat = params[:repeat]
    xpath = "//part[@type='#{type}']//item[@id='#{id}']"
    if params[:flag] == "true"
      if step == "3" && repeat == "0"
        #pass
        rewrite_xml_item(xpath, nil, "true", nil, nil)
      elsif step != "3" && repeat == "0"
        #step + 1
        rewrite_xml_item(xpath, nil, nil, nil, step.to_i + 1)
      elsif repeat != "0"
        #repeat - 1
        rewrite_xml_item(xpath, nil, nil, repeat.to_i - 1, nil)
      end
    else
      #repeat = 2
      rewrite_xml_item(xpath, nil, nil, 2, nil)
    end
  end
  
  def rewrite_xml_item(xpath, path, is_pass, repeat_time, step)
    plan = UserPlan.where(["user_id = ? and category_id = ?", cookies[:user_id], 2]).first
    xml = REXML::Document.new(File.open(Constant::PUBLIC_PATH + plan.plan_url)) if plan
    element = xml.elements["//plan//_#{xml.elements['//current'].text}"+xpath]
    p element
    element.add_attribute("is_pass","true")
  end
  
  def operate_word(items)
    result = nil
    wid = items[0].split("-")[0]
    repeat = items[0].split("-")[1]
    step = items[0].split("-")[2].to_i + 1
    type = UserPlan::CHAPTER_TYPE_NUM[:WORD]
    word = Word.find(wid)
    if (step != 3)
      options = Word.get_words_by_level(word.level, word.category_id, 3, wid) << word
      result = {
        :type => type,
        :step => step,
        :repeat => repeat,
        :time => Constant::WORD_TIME[step],
        :word => word,
        :options => options.sort_by { rand }
      }
    else
      result = {
        :type => type,
        :step => step,
        :repeat => repeat,
        :time => Constant::WORD_TIME[step],
        :word => word.name,
        :sentence => WordSentence.find_all_by_word_id(wid).first.description.gsub(word.name,"_______")
      }
    end
    return result
  end

  def operate_sentence(id, step)
    result = nil
    type = UserPlan::CHAPTER_TYPE_NUM[:SENTENCE]
    id = get_exerise_id(type) unless id
    return operate_listen(nil, 1) unless id
    sentence = PracticeSentence.find(id)
    result = {
      :type => type,
      :step => step,
      :time => Constant::SENTENCE_TIME[step],
      :sentence => sentence
    }
    p result
    return result
  end

  def willdo_part_infos
    plan = UserPlan.where(["user_id = ? and category_id = ?", cookies[:user_id], 2]).first
    xml = REXML::Document.new(File.open(Constant::PUBLIC_PATH + plan.plan_url)) if plan
    xpath = "//plan//_#{xml.elements["//current"].text}[@status='#{UserPlan::PLAN_STATUS[:UNFINISHED]}']//part[@status='#{UserPlan::PLAN_STATUS[:UNFINISHED]}']"
    node = xml.elements[xpath]
    return nil unless !node.nil?
    return {:type => node.attribute["type"], :ids => node.elements.each("item"){}.inject(Array.new) { |arr, a| arr.push("#{a.attribute['id']}-#{a.attribute['repeat_time']}-#{a.attribute['step']}") } }
  end

  def get_item(type)
    plan = UserPlan.where(["user_id = ? and category_id = ?", 2, 2]).first
    xml = REXML::Document.new(File.open(Constant::PUBLIC_PATH + plan.plan_url)) if plan
    current_index = xml.elements["//current"].text
    current_part = nil
    xml.elements.each("//plan//_#{current_index}//part") { |i| current_part = i if i.attribute["type"].to_i == type }
    current_part.elements.each("item") { |j| return j.attribute["id"] if j.attribute["is_pass"] == "false" }
    return nil
  end
end
