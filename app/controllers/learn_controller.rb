#encoding: utf-8
class LearnController < ApplicationController
  layout 'main'
  require 'rexml/document'
  include REXML
  include Oauth2Helper
  before_filter :sign?

  respond_to :html, :xml, :json, :js

  def task_dispatch
    plan = UserPlan.find_by_category_id_and_user_id(params[:category].to_i, cookies[:user_id].to_i)
    xml = plan.plan_list_xml
    cookies[:can_open] = Sun.open_package(cookies[:user_id].to_i, params[:category].to_i, xml)
    if is_vip?(params[:category]) or cookies[:can_open]
      cookies[:category] = params[:category]
      cookies[:modulus] = UserScoreInfo.find_by_category_id_and_user_id(cookies[:category].to_i, cookies[:user_id].to_i).modulus
      items = params[:items].split(",") if params[:items]
      if items.nil? or items.blank?
        return if (info = willdo_part_infos(plan, xml)).nil?
        cookies[:type] = info[:type].to_i
        cookies[:complete_item] = info[:complete_item]
        items = info[:ids]
      end
      if !params[:ids].nil? && !params[:ids].empty?
        @ids_str = params[:ids]
      else
        @ids_str = items.inject(Array.new) { |arr,item| arr.push(item.split("-")[0]) }.join(",")
      end
      @items_str = items.join(",")
      cookies[:current_id] = items[0].split("-")[0] if items[0]
      case cookies[:type].to_i
      when UserPlan::CHAPTER_TYPE_NUM[:WORD]
        @result = operate_word(items)
      when UserPlan::CHAPTER_TYPE_NUM[:SENTENCE]
        @result = operate_sentence(items)
      when UserPlan::CHAPTER_TYPE_NUM[:LINSTEN]
        @result = operate_hearing
      when UserPlan::CHAPTER_TYPE_NUM[:READ]
        @result = operate_reading
      when UserPlan::CHAPTER_TYPE_NUM[:TRANSLATE]
        if cookies[:learn_step].to_i==1
          cookies[:item_ids]=nil
          @result = operate_translate_one
        else
          items=items.reject {|i|  i.split("-")[2].to_i != 0 }
          unless items.blank?
            @items_str = items.join(",")
            @ids_str = items.inject(Array.new) { |arr,item| arr.push(item.split("-")[0]) }.join(",")
            @result = operate_translate(items)
          else
            cookies[:learn_step]=1
            @result = operate_translate_one
          end
        end
      when UserPlan::CHAPTER_TYPE_NUM[:DICTATION]
        cookies[:learn_step]=nil
        @result=operate_listen
      when UserPlan::CHAPTER_TYPE_NUM[:WRITE]
        cookies[:learn_step]=nil
        @result=operate_write
      when UserPlan::CHAPTER_TYPE_NUM[:SIMILAR]
        @result=operate_similar(@ids_str)
      end
    end
  end

  #判断特殊情况，如果第一部分item-status置为1，但是part-satus未置为1
  def next_part_info(xpath, plan, xml)
    node = xml.elements[xpath]
    if !node.nil? and node.elements["item[@is_pass='#{UserPlan::PLAN_STATUS[:UNFINISHED]}']"].nil?
      node.add_attribute("status", UserPlan::PLAN_STATUS[:FINISHED])
      f = File.new(Constant::PUBLIC_PATH + plan.plan_url,"w+")
      f.write("#{xml.to_s.force_encoding('UTF-8')}")
      f.close
    end
    return xpath
  end

  #获取目前已经做完的题
  def count_complete_item(node)
    all_length = node.get_elements("item").nil? ? 0 : node.get_elements("item").length
    return all_length
  end


  #取出当前part的items 并组装 [id-repeat_time-step]
  def willdo_part_infos(plan, xml)
    review = willdo_review_infos(plan, xml)
    return review if !review.nil?
    xpath = "//plan//_#{xml.elements["//current"].text}[@status='#{UserPlan::PLAN_STATUS[:UNFINISHED]}']//part[@status='#{UserPlan::PLAN_STATUS[:UNFINISHED]}']"
    xpath = next_part_info(xpath, plan, xml)
    node = xml.elements[xpath]
    return nil if node.nil?
    item_length = count_complete_item(node)
    cookies[:is_new] = "plan"
    return {:type => node.attributes["type"], :complete_item => "#{item_length}",
      :ids => node.elements.each("item[@is_pass='#{UserPlan::PLAN_STATUS[:UNFINISHED]}']"){}.inject(Array.new) { |arr, a| arr.push("#{a.attributes['id']}-#{a.attributes['repeat_time']}-#{a.attributes['step']}") } }
  end

  def willdo_review_infos(plan, xml)
    xpath = "//review//_#{xml.elements["//current"].text}[@status='#{UserPlan::PLAN_STATUS[:UNFINISHED]}']//part[@status='#{UserPlan::PLAN_STATUS[:UNFINISHED]}']"
    xpath = next_part_info(xpath, plan, xml)
    node = xml.elements[xpath]
    return nil if node.nil?
    item_length = count_complete_item(node)
    cookies[:is_new] = "review"
    return {:type => node.attributes["type"], :complete_item => "#{item_length}",
      :ids => node.elements.each("item[@is_pass='#{UserPlan::PLAN_STATUS[:UNFINISHED]}']"){}.inject(Array.new) { |arr, a| arr.push("#{a.attributes['id']}-#{a.attributes['repeat_time']}-#{a.attributes['step']}") } }
  end

  def operate_word(items)
    result = nil
    repeat = items[0].split("-")[1]
    step = items[0].split("-")[2].to_i + 1
    step = 3 if step > 3
    word = Word.find(cookies[:current_id])
    if (step != 3)
      options = Word.get_words_by_level(word.level, 3, cookies[:current_id]) << word
      result = {
        :type => cookies[:type],
        :step => step,
        :repeat => repeat,
        :time => (Constant::WORD_TIME[step] * cookies[:modulus].to_f).to_i,
        :word => word,
        :options => options.sort_by { rand }
      }
    else
      result = {
        :type => cookies[:type],
        :step => step,
        :repeat => repeat,
        :time => (Constant::WORD_TIME[step] * cookies[:modulus].to_f).to_i,
        :word => word,
        :sentence => WordSentence.find_by_word_id(cookies[:current_id]).nil? ? "" : WordSentence.find_by_word_id(cookies[:current_id]).description
      }
    end
    return result
  end

  def operate_sentence(items)
    result = nil
    sentence = PracticeSentence.find(cookies[:current_id])
    step = items[0].split("-")[2].to_i + 1
    step = 2 if step > 2
    words = sentence_words(sentence.en_mean)
    rtime = Constant::SENTENCE_TIME[:READ] * words.length  * cookies[:modulus].to_f
    ctime = Constant::SENTENCE_TIME[:COMBIN] * words.length  * cookies[:modulus].to_f
    rtime = ctime  if step == 2
    result = {
      :type => cookies[:type],
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
    listen = PracticeSentence.find(cookies[:current_id])
    words = sentence_words(listen.en_mean)
    time = words.length * Constant::LISTEN_TIME[:PER] * cookies[:modulus].to_f
    result = {
      :type => cookies[:type],
      :time => time.to_i,
      :listen => listen
    }
    return result
  end

  def operate_reading
    result = nil
    tractate = Tractate.find(cookies[:current_id])
    xml = tractate.tractate_xml if tractate
    description = xml.elements["//description"].elements.each("p"){}.inject(Array.new){ |arr,a| arr.push(a.text) }
    time = description.inject(0){ |result, element| result + sentence_words(element.gsub("[]","")).length * Constant::READ_TIME[:DEFAULT] * cookies[:modulus].to_f }
    questions =  xml.elements["//questions"].elements.each("question"){}.inject(Array.new) { |array, a|
      array.push({:id => a.attributes["id"],:title => a.elements["title"].text, :options => a.elements["options"].text.split("[]").sort_by { rand },:answer => a.elements["answer"].text}) }
    result = {
      :type => cookies[:type],
      :description => description,
      :time => time.to_i,
      :qtime => Constant::READ_TIME[:QUESTION],
      :questions => questions
    }
    return result
  end

  def jude_word
    plan = UserPlan.find_by_category_id_and_user_id(cookies[:category].to_i, cookies[:user_id].to_i)
    xml = plan.plan_list_xml
    items = params[:items].split(",")
    ids = params[:ids].split(",")
    repeat = items[0].split("-")[1].to_i
    step = items[0].split("-")[2].to_i  #当前要进行的步骤 1、2、3
    xpath = "//part[@type='#{cookies[:type]}']//item[@id='#{cookies[:current_id]}']"
    elem = nil
    if params[:flag] == "true"
      if repeat == 0 or repeat == 1
        if step == 0 or step == 1
          elem = "#{cookies[:current_id]}-0-#{step+1}"
          rewrite_xml_item(plan, xml, xpath, nil, 0, step + 1)
        elsif step == 2
          elem = "#{cookies[:current_id]}-0-#{step+1}"
          rewrite_xml_item(plan, xml, xpath, UserPlan::PLAN_STATUS[:FINISHED], 0, step + 1)
        end
      elsif repeat == 2
        elem = "#{cookies[:current_id]}-1-#{step}"
        rewrite_xml_item(plan, xml, xpath, nil, 1, step)
      end
    else
      elem = "#{cookies[:current_id]}-2-#{step}"
      rewrite_xml_item(plan, xml, xpath, nil, 2, nil)
    end
    if (step == 2 && repeat <= 1 && params[:flag] == "true")
      ids = ids - [items[0].split("-")[0]]
      items = items - [items[0]]
    else
      items = (items - [items[0]]).push(elem)
    end
    xml = pass_status(plan, xml, "part") if items.blank?
    @status = is_part_pass?(plan, xml)
    @items_str = items.join(",")
    @flag = params[:flag]
    @ids_str = ids.join(",")
    @redirct = params[:redirct]
  end

  def jude_sentence
    plan = UserPlan.find_by_category_id_and_user_id(cookies[:category].to_i, cookies[:user_id].to_i)
    xml = plan.plan_list_xml
    items =  params[:items].split(",")
    ids = params[:ids].split(",")
    step =  items[0].split("-")[2].to_i  #当前要进行的步骤 1、2
    xpath = "//part[@type='#{cookies[:type]}']//item[@id='#{cookies[:current_id]}']"
    if params[:flag] == "true"
      if step == 1
        ids = ids - [items[0].split("-")[0]]
        items = items - [items[0]]
        rewrite_xml_item(plan, xml, xpath, UserPlan::PLAN_STATUS[:FINISHED], nil, nil)
      else
        items = (items - [items[0]]).push("#{cookies[:current_id]}-0-#{step+1}")
        rewrite_xml_item(plan, xml, xpath, nil, nil, step + 1)
      end
    else
      items = (items - [items[0]]).push(items[0])
    end
    xml = pass_status(plan, xml, "part") if items.blank?
    @status = is_part_pass?(plan, xml)
    @flag = params[:flag]
    @items_str = items.join(",")
    @ids_str = ids.join(",")
    @redirct = params[:redirct]
  end

  def jude_hearing
    plan = UserPlan.find_by_category_id_and_user_id(cookies[:category].to_i, cookies[:user_id].to_i)
    xml = plan.plan_list_xml
    items =  params[:items].split(",")
    ids = params[:ids].split(",")
    xpath = "//part[@type='#{cookies[:type]}']//item[@id='#{cookies[:current_id]}']"
    if params[:flag] == "true"
      rewrite_xml_item(plan, xml, xpath, UserPlan::PLAN_STATUS[:FINISHED], nil, nil)
      ids = ids - [items[0].split("-")[0]]
      items = items - [items[0]]
    else
      items = (items - [items[0]]).push(items[0])
    end
    if items.blank?
      xml = pass_status(plan, xml, "part")
    end
    @status = is_part_pass?(plan, xml)
    @flag = params[:flag]
    @items_str = items.join(",")
    @ids_str = ids.join(",")
    @redirct = params[:redirct]
  end

  def jude_read
    plan = UserPlan.find_by_category_id_and_user_id(cookies[:category].to_i, cookies[:user_id].to_i)
    xml = plan.plan_list_xml
    items =  params[:items].split(",")
    ids = params[:ids].split(",")
    xpath = "//part[@type='#{cookies[:type]}']//item[@id='#{cookies[:current_id]}']"
    if params[:flag] == "true"
      rewrite_xml_item(plan, xml, xpath, UserPlan::PLAN_STATUS[:FINISHED], nil, nil)
      ids = ids - [items[0].split("-")[0]]
      items = items - [items[0]]
    else
      items = (items - [items[0]]).push(items[0])
    end
    xml = pass_status(plan, xml, "part") if items.blank?
    @status = is_part_pass?(plan, xml)
    @items_str = items.join(",")
    @ids_str = ids.join(",")
    @redirct = params[:redirct]
  end

  def i_have_remember
    plan = UserPlan.find_by_category_id_and_user_id(cookies[:category].to_i, cookies[:user_id].to_i)
    xml = plan.plan_list_xml
    items =  params[:items].split(",")
    ids = params[:ids].split(",")
    type = cookies[:type].to_i
    xpath = "//part[@type='#{type}']//item[@id='#{cookies[:current_id]}']"
    node = xml.elements["//#{cookies[:is_new]}//_#{xml.elements['//current'].text}"+xpath]
    current_item = "#{node.attributes['id']}-#{node.attributes['repeat_time']}-#{node.attributes['step']}"
    rewrite_xml_item(plan, xml, xpath, UserPlan::PLAN_STATUS[:FINISHED], nil, nil)
    ids = ids - [cookies[:current_id]]
    items = items - [current_item]
    pass_status(plan, xml, "part") if items.blank?
    @status = is_part_pass?(plan, xml)
    @current_step = params[:current_step]
    @items_str = items.join(",")
    @ids_str = ids.join(",")
    @redirct = "true"
  end

  def rewrite_xml_item(plan, xml, xpath, is_pass, repeat_time, step)
    element = xml.elements["//#{cookies[:is_new]}//_#{xml.elements['//current'].text}"+xpath]
    element.add_attribute("is_pass", UserPlan::PLAN_STATUS[:FINISHED]) if is_pass == UserPlan::PLAN_STATUS[:FINISHED]
    element.add_attribute("repeat_time", repeat_time) if repeat_time
    element.add_attribute("step", step) if step
    f = File.new(Constant::PUBLIC_PATH + plan.plan_url,"w+")
    f.write("#{xml.to_s.force_encoding('UTF-8')}")
    f.close
  end

  def pass_status(plan, xml, kind) #kind = 部分 or 整个包
    if kind == "part"
      element = xml.elements["//#{cookies[:is_new]}//_#{xml.elements['//current'].text}//part[@type=#{cookies[:type]}]"]
    else
      element = xml.elements["//#{cookies[:is_new]}//_#{xml.elements['//current'].text}"]
    end
    element.add_attribute("status", UserPlan::PLAN_STATUS[:FINISHED])
    f = File.new(Constant::PUBLIC_PATH + plan.plan_url,"w+")
    f.write("#{xml.to_s.force_encoding('UTF-8')}")
    f.close
    return xml
  end

  def is_part_pass?(plan, xml)
    current = xml.elements["//current"].text
    xpath = "//#{cookies[:is_new]}//_#{current}[@status='#{UserPlan::PLAN_STATUS[:UNFINISHED]}']//part[@status='#{UserPlan::PLAN_STATUS[:UNFINISHED]}']"
    node = xml.elements[xpath]
    if node.nil?
      pass_status(plan, xml, "all")
      if cookies[:is_new] == "plan"
        plan.update_plan
        ActionLog.study_plan_log(cookies[:user_id].to_i)
        send_message("我在赶考网完成了我#{Category::TYPE_INFO[plan.category_id]}第#{current}个学习任务，距离成功又进一步，加油！(*^__^*) ……",
          cookies[:user_id].to_i)
      end
      return true
    end
    return false
  end



  def study_it
    @result = nil
    if cookies[:type].to_i == UserPlan::CHAPTER_TYPE_NUM[:WORD]
      @result = {
        :word => Word.find(cookies[:current_id]),
        :sentences => WordSentence.find_all_by_word_id(cookies[:current_id])
      }
    elsif cookies[:type].to_i == UserPlan::CHAPTER_TYPE_NUM[:SENTENCE]
      @result = {
        :sentence => PracticeSentence.find(cookies[:current_id])
      }
    elsif cookies[:type].to_i == UserPlan::CHAPTER_TYPE_NUM[:LINSTEN]
      @result = {
        :sentence => PracticeSentence.find(cookies[:current_id])
      }
    elsif cookies[:type].to_i == UserPlan::CHAPTER_TYPE_NUM[:TRANSLATE]
      if cookies[:learn_step].to_i==1
        @result = {
          :sentence => PracticeSentence.find(cookies[:current_id])
        }
      else
        @result = {
          :sentence => PracticeSentence.find_by_sql("select id,ch_mean,en_mean from practice_sentences where id in (#{cookies[:item_ids]})")
        }
      end
    elsif cookies[:type].to_i == UserPlan::CHAPTER_TYPE_NUM[:DICTATION]
      @result = {
        :sentence => PracticeSentence.find(cookies[:current_id])
      }
    end

    return @result
  end

  def sentence_words(str)
    return str.gsub(/"/," ").split(" ")
  end

  
  #----Start-------听写过程--------Start----
  def operate_listen
    sentence=PracticeSentence.find(cookies[:current_id])
    time=sentence_words(sentence.en_mean).length
    return  {:type => cookies[:type], 
      :time =>(time * Constant::DICTATION[:PRE] * cookies[:modulus].to_f).to_i,
      :sentence =>sentence}
  end

  def jude_listen
    plan = UserPlan.find_by_category_id_and_user_id(cookies[:category].to_i, cookies[:user_id].to_i)
    xml = plan.plan_list_xml
    items =  params[:items].split(",")
    ids = params[:ids].split(",")
    xpath = "//part[@type='#{cookies[:type]}']//item[@id='#{cookies[:current_id]}']"
    if params[:flag] == "true"
      ids = ids - [items[0].split("-")[0]]
      items = items - [items[0]]
      rewrite_xml_item(plan, xml, xpath, UserPlan::PLAN_STATUS[:FINISHED], nil, nil)
    else
      items = (items - [items[0]]).push(items[0])
    end
    xml = pass_status(plan, xml, "part") if items.blank?
    @status = is_part_pass?(plan, xml)
    @flag = params[:flag]
    @items_str = items.join(",")
    @ids_str = ids.join(",")
    @redirct = params[:redirct]
  end

  #-----End------听写过程------End------

  

  #---------------start 翻译拖拽--------------------start
  
  def operate_translate(items)
    item_ids=items[0..4].inject(Array.new) { |arr,item| arr.push(item.split("-")[0]) }.join(",")
    sentences=PracticeSentence.find_by_sql("select id,ch_mean,en_mean from practice_sentences where id in (#{item_ids})")
    time=sentences[0..4].inject(0) { |time,item|  time+sentence_words(item.en_mean).length }
    return  {:type => cookies[:type], 
      :time =>(time * Constant::TRANSLATE[:ONE] * cookies[:modulus].to_f).to_i,
      :sentence =>sentences}
  end

  def jude_translate
    plan = UserPlan.find_by_category_id_and_user_id(cookies[:category].to_i, cookies[:user_id].to_i)
    xml = plan.plan_list_xml
    items =  params[:items].split(",")
    ids = params[:ids].split(",")
    correct_ids=params[:correct_ids].split(",")
    correct_ids.each do |i|
      xpath = "//part[@type='#{cookies[:type]}']//item[@id='#{i}']"
      item=items[ids.index(i)]
      ids = ids - [i]
      items = items - [item]
      rewrite_xml_item(plan, xml, xpath, nil, nil, 1)
    end
    wrong_items=items[0..(4-correct_ids.length)]
    ids[0..(4-correct_ids.length)].each do |id|
      wrong_items.each do |wrong|
        if id==wrong.split("-")[0]
          items=(items-[wrong]).push(wrong)
          ids=(ids-[id]).push(id)
        end
      end
    end
    @status = false
    @items_str = items.join(",")
    @ids_str = ids.join(",")
    @redirct = params[:redirct]
  end

  #单个翻译
  def operate_translate_one
    sentence=PracticeSentence.find(cookies[:current_id])
    time=sentence_words(sentence.en_mean).length
    return  {:type => cookies[:type], 
      :time =>(time * Constant::TRANSLATE[:TWO] * cookies[:modulus].to_f).to_i,
      :sentence =>sentence}
  end

  def jude_translate_one
    plan = UserPlan.find_by_category_id_and_user_id(cookies[:category].to_i, cookies[:user_id].to_i)
    xml = plan.plan_list_xml
    items =  params[:items].split(",")
    ids = params[:ids].split(",")
    xpath = "//part[@type='#{cookies[:type]}']//item[@id='#{cookies[:current_id]}']"
    if params[:flag] == "true"
      ids = ids - [items[0].split("-")[0]]
      items = items - [items[0]]
      rewrite_xml_item(plan, xml, xpath, UserPlan::PLAN_STATUS[:FINISHED], nil, nil)
    else
      items = (items - [items[0]]).push(items[0])
    end
    xml = pass_status(plan, xml, "part") if items.blank?
    @status =is_part_pass?(plan, xml)
    @flag = params[:flag]
    @items_str = items.join(",")
    @ids_str = ids.join(",")
    @redirct = params[:redirct]
  end
  #---------------end 翻译拖拽--------------------end

  #---------------start 写作--------------------start
  def operate_write
    tractate_url=Constant::BACK_PUBLIC_PATH+Tractate.find(cookies[:current_id]).tractate_url
    xml=list_xml(tractate_url)
    context=xml.elements["/root/description/p"].text
    list_words=context.gsub(/([\(\)\[\]\{\}\^\$\+\-\*\?\,\.\"\'\|\/\\])/," ").split(" ")
    words =[]
    (0..5).each do |i|
      words << list_words.delete(list_words.max_by {|word|  word.length })
    end
    return  {:type => cookies[:type], :time => Constant::WRITE[:PRE], :sentence =>words.join(" "),:context=>context}
  end

  def list_xml(url)
    file=File.open (url)
    doc = Document.new(file)
    file.close
    return doc
  end

  def jude_write
    plan = UserPlan.find_by_category_id_and_user_id(cookies[:category].to_i, cookies[:user_id].to_i)
    xml = plan.plan_list_xml
    items =  params[:items].split(",")
    ids = params[:ids].split(",")
    xpath = "//part[@type='#{cookies[:type]}']//item[@id='#{cookies[:current_id]}']"
    if params[:flag] == "true"
      ids = ids - [items[0].split("-")[0]]
      items = items - [items[0]]
      rewrite_xml_item(plan, xml, xpath, UserPlan::PLAN_STATUS[:FINISHED], nil, nil)
    else
      items = (items - [items[0]]).push(items[0])
    end
    xml = pass_status(plan, xml, "part") if items.blank?
    @status = is_part_pass?(plan, xml)
    @flag = params[:flag]
    @items_str = items.join(",")
    @ids_str = ids.join(",")
    @redirct = params[:redirct]
  end

  #---------------end 翻译拖拽--------------------end

  def operate_similar(id)
    plan = UserPlan.find_by_category_id_and_user_id(cookies[:category].to_i, cookies[:user_id].to_i)
    xml = plan.plan_list_xml
    xpath = "//part[@type='#{cookies[:type]}']//item[@id='#{id}']"
    num= xml.elements["//#{cookies[:is_new]}//_#{xml.elements['//current'].text}"+xpath].attributes["num"]
    return {:type => cookies[:type],:time=>num}
  end


  def check_similar
    plan = UserPlan.find_by_category_id_and_user_id(params[:category].to_i, cookies[:user_id].to_i)
    xml = plan.plan_list_xml
    inner_chapt=xml.root.elements["plan/current"].text.to_i
    total_bag= xml.root.elements["plan/info/chapter1"].attributes["days"].to_i+xml.root.elements["plan/info/chapter2"].attributes["days"].to_i
    each_num=xml.root.elements["plan/info/chapter3"].attributes["similarity"].to_i
    if total_bag >= inner_chapt
      data="您还没有真题包"
    else
      total_actions=ActionLog.find_by_sql("select sum(total_num) num from action_logs where user_id=#{cookies[:user_id]}
   and category_id=#{params[:category].to_i} and types=#{ActionLog::TYPES[:PRACTICE]}")[0]
      if (inner_chapt-total_bag)*each_num <=  total_actions.num.to_i
        is_part_pass?(plan, xml)
        data="第#{(inner_chapt+1)<plan.days ? (inner_chapt+1) : plan.days }个包已解锁"
      else
        data="您还需要#{(inner_chapt-total_bag)*each_num-total_actions.num.to_i}道真题才能解锁下一个包"
      end
    end
    respond_to do |format|
      format.json {
        render :json=>{:message=>data}
      }
    end
  end
  
end
