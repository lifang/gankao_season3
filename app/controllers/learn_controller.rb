#encoding: utf-8
class LearnController < ApplicationController
  layout 'main'
  require 'rexml/document'
  include REXML

  respond_to :html, :xml, :json, :js
  
  def task_dispatch
    cookies[:category] = params[:category]
    cookies[:modulus] = UserScoreInfo.where(["user_id = ? and category_id = ?",
        cookies[:user_id], cookies[:category]]).first.modulus
    items = params[:items].split(",") if params[:items]
    if items.nil? or items.blank?
      return if (info = willdo_part_infos).nil?
      cookies[:type] = info[:type].to_i
      items = info[:ids]
    end
    if !params[:ids].nil? && !params[:ids].empty?
      @ids_str = params[:ids]
    else
      @ids_str = items.inject(Array.new) { |arr,item| arr.push(item.split("-")[0]) }.join(",")
    end
    p @ids_str
    
    @items_str = items.join(",")
    cookies[:current_id] = items[0].split("-")[0] if items[0]
    p  cookies[:current_id]
    p @items_str
    case cookies[:type].to_i
    when UserPlan::CHAPTER_TYPE_NUM[:WORD]
      @result = operate_word(items)
    when UserPlan::CHAPTER_TYPE_NUM[:SENTENCE]
      @result = operate_sentence(items)
    when UserPlan::CHAPTER_TYPE_NUM[:LINSTEN]
      @result = operate_hearing
    when UserPlan::CHAPTER_TYPE_NUM[:READ]
      @result = operate_reading
    end
  end
  
  #取出当前part的items 并组装 [id-repeat_time-step]
  def willdo_part_infos
    review = willdo_review_infos
    return review if !review.nil?
    
    plan = UserPlan.where(["user_id = ? and category_id = ?", cookies[:user_id], cookies[:category]]).first
    xml = REXML::Document.new(File.open(Constant::PUBLIC_PATH + plan.plan_url)) if plan
    xpath = "//plan//_#{xml.elements["//current"].text}[@status='#{UserPlan::PLAN_STATUS[:UNFINISHED]}']//part[@status='#{UserPlan::PLAN_STATUS[:UNFINISHED]}']"
    node = xml.elements[xpath]
    return nil unless !node.nil?
    cookies[:is_new] = "plan"
    return {:type => node.attributes["type"], :ids => node.elements.each("item[@is_pass='#{UserPlan::PLAN_STATUS[:UNFINISHED]}']"){}.inject(Array.new) { |arr, a| arr.push("#{a.attributes['id']}-#{a.attributes['repeat_time']}-#{a.attributes['step']}") } }
  end

  def willdo_review_infos
    plan = UserPlan.where(["user_id = ? and category_id = ?", cookies[:user_id], cookies[:category]]).first
    xml = REXML::Document.new(File.open(Constant::PUBLIC_PATH + plan.plan_url)) if plan
    xpath = "//review//_#{xml.elements["//current"].text}[@status='#{UserPlan::PLAN_STATUS[:UNFINISHED]}']//part[@status='#{UserPlan::PLAN_STATUS[:UNFINISHED]}']"
    node = xml.elements[xpath]
    return nil unless !node.nil?
    cookies[:is_new] = "review"
    return {:type => node.attributes["type"], :ids => node.elements.each("item[@is_pass='#{UserPlan::PLAN_STATUS[:UNFINISHED]}']"){}.inject(Array.new) { |arr, a| arr.push("#{a.attributes['id']}-#{a.attributes['repeat_time']}-#{a.attributes['step']}") } }
  end

  def operate_word(items)
    result = nil
    repeat = items[0].split("-")[1]
    step = items[0].split("-")[2].to_i + 1
    step = 3 if step > 3
    word = Word.find(cookies[:current_id])
    if (step != 3)
      options = Word.get_words_by_level(word.level, word.category_id, 3, cookies[:current_id]) << word
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
        :sentence => WordSentence.find_all_by_word_id(cookies[:current_id]).first.description.gsub(word.name,"_______")
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
    options = PracticeSentence.get_listen_by_level(listen.level, listen.category_id, listen.types, 1, cookies[:current_id]) << listen
    result = {
      :type => cookies[:type],
      :time => time.to_i,
      :listen => listen,
      :options => options.sort_by { rand }
    }
    return result
  end

  def operate_reading
    result = nil
    path = Tractate.find(cookies[:current_id]).tractate_url
    xml = REXML::Document.new(File.open(Constant::PUBLIC_PATH + path)) if path
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
          rewrite_xml_item(xpath, nil, 0, step + 1)
        elsif step == 2
          elem = "#{cookies[:current_id]}-0-#{step+1}"
          rewrite_xml_item(xpath, UserPlan::PLAN_STATUS[:FINISHED], 0, step + 1)
        end
      elsif repeat == 2
        elem = "#{cookies[:current_id]}-1-#{step}"
        rewrite_xml_item(xpath, nil, 1, step)
      end
    end
    if params[:flag] == "false"
      elem = "#{cookies[:current_id]}-2-#{step}"
      rewrite_xml_item(xpath, nil, 2, nil)
    end
    if (step == 2 && repeat <= 1 && params[:flag] == "true")
      ids = ids - [items[0].split("-")[0]]
      items = items - [items[0]]
    else
      items = (items - [items[0]]).push(elem)
    end
    pass_status("part") if items.blank?
    @status = is_part_pass?
    @items_str = items.join(",")
    @flag = params[:flag]
    @ids_str = ids.join(",")
    @redirct = params[:redirct]
  end

  def jude_sentence
    items =  params[:items].split(",")
    ids = params[:ids].split(",")
    step =  items[0].split("-")[2].to_i  #当前要进行的步骤 1、2
    xpath = "//part[@type='#{cookies[:type]}']//item[@id='#{cookies[:current_id]}']"
    if params[:flag] == "true"
      if step == 1
        ids = ids - [items[0].split("-")[0]]
        items = items - [items[0]]
        rewrite_xml_item(xpath, UserPlan::PLAN_STATUS[:FINISHED], nil, nil)
      else
        items = (items - [items[0]]).push("#{cookies[:current_id]}-0-#{step+1}")
        rewrite_xml_item(xpath, nil, nil, step + 1)
      end
    else
      items = (items - [items[0]]).push(items[0])
    end
    pass_status("part") if items.blank?
    @status = is_part_pass?
    @flag = params[:flag]
    @items_str = items.join(",")
    @ids_str = ids.join(",")
    @redirct = params[:redirct]
  end

  def jude_hearing
    items =  params[:items].split(",")
    ids = params[:ids].split(",")
    xpath = "//part[@type='#{cookies[:type]}']//item[@id='#{cookies[:current_id]}']"
    if params[:flag] == "true"
      rewrite_xml_item(xpath, UserPlan::PLAN_STATUS[:FINISHED], nil, nil)
      ids = ids - [items[0].split("-")[0]]
      items = items - [items[0]]
    else
      items = (items - [items[0]]).push(items[0])
    end
    if items.blank?
      pass_status("part")
    end
    @status = is_part_pass?
    @flag = params[:flag]
    @items_str = items.join(",")
    @ids_str = ids.join(",")
    @redirct = params[:redirct]
  end

  def jude_read
    items =  params[:items].split(",")
    ids = params[:ids].split(",")
    xpath = "//part[@type='#{cookies[:type]}']//item[@id='#{cookies[:current_id]}']"
    if params[:flag] == "true"
      rewrite_xml_item(xpath, UserPlan::PLAN_STATUS[:FINISHED], nil, nil)
      ids = ids - [items[0].split("-")[0]]
      items = items - [items[0]]
    else
      items = (items - [items[0]]).push(items[0])
    end
    pass_status("part") if items.blank?
    @status = is_part_pass?
    @items_str = items.join(",")
    @ids_str = ids.join(",")
    @redirct = params[:redirct]
  end

  def i_have_remember
    items =  params[:items].split(",")
    ids = params[:ids].split(",")
    type = UserPlan::CHAPTER_TYPE_NUM[:WORD]
    xpath = "//part[@type='#{type}']//item[@id='#{cookies[:current_id]}']"
    rewrite_xml_item(xpath, UserPlan::PLAN_STATUS[:FINISHED], nil, nil)
    ids = ids - [cookies[:current_id]]
    items = items - [items[0]]
    pass_status("part") if items.blank?
    @items_str = items.join(",")
    @ids_str = ids.join(",")
    @redirct = "true"
  end
  
  def rewrite_xml_item(xpath, is_pass, repeat_time, step)
    plan = UserPlan.where(["user_id = ? and category_id = ?", cookies[:user_id], cookies[:category]]).first
    xml = REXML::Document.new(File.open(Constant::PUBLIC_PATH + plan.plan_url)) if plan
    element = xml.elements["//#{cookies[:is_new]}//_#{xml.elements['//current'].text}"+xpath]
    element.add_attribute("is_pass", UserPlan::PLAN_STATUS[:FINISHED]) if is_pass == UserPlan::PLAN_STATUS[:FINISHED]
    element.add_attribute("repeat_time", repeat_time) if repeat_time
    element.add_attribute("step", step) if step
    f = File.new(Constant::PUBLIC_PATH + plan.plan_url,"w+")
    f.write("#{xml.to_s.force_encoding('UTF-8')}")
    f.close
  end

  def pass_status(kind) #kind = 部分 or 整个包
    plan = UserPlan.where(["user_id = ? and category_id = ?", cookies[:user_id], cookies[:category]]).first
    xml = REXML::Document.new(File.open(Constant::PUBLIC_PATH + plan.plan_url)) if plan
    if kind == "part"
      element = xml.elements["//#{cookies[:is_new]}//_#{xml.elements['//current'].text}//part[@type=#{cookies[:type]}]"]
    else
      element = xml.elements["//#{cookies[:is_new]}//_#{xml.elements['//current'].text}"]
    end
    element.add_attribute("status", UserPlan::PLAN_STATUS[:FINISHED])
    f = File.new(Constant::PUBLIC_PATH + plan.plan_url,"w+")
    f.write("#{xml.to_s.force_encoding('UTF-8')}")
    f.close
  end

  def is_part_pass?
    plan = UserPlan.where(["user_id = ? and category_id = ?", cookies[:user_id], cookies[:category]]).first
    xml = REXML::Document.new(File.open(Constant::PUBLIC_PATH + plan.plan_url)) if plan
    current = xml.elements["//current"].text
    xpath = "//#{cookies[:is_new]}//_#{current}[@status='#{UserPlan::PLAN_STATUS[:UNFINISHED]}']//part[@status='#{UserPlan::PLAN_STATUS[:UNFINISHED]}']"
    node = xml.elements[xpath]
    if node.nil?
      pass_status("all")
      UserPlan.where(["user_id = ? and category_id = ?", cookies[:user_id], cookies[:category]]).first.update_plan if cookies[:is_new] == "plan"
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
    end
    return @result
  end

  def sentence_words(str)
    return str.gsub(/"/," ").gsub(/:/," ").gsub(/;/," ").gsub(/\?/," ").gsub(/!/," ").gsub(/,/," ").gsub(/\./," ").gsub(/  /," ").split(" ")
  end



  #----Start-------听写过程--------Start----
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
    @index=params[:index].to_i
    @listen_ids=params[:ids].split(",").to_a
    p @listen_ids
    #题目类型  5为听写
    part_type=UserPlan::CHAPTER_TYPE_NUM[:DICTATION].to_s
    #获取用户xml路径
    x_url = "#{Rails.root}/public/plan_xmls/2012-08/2_19.xml"
    xml =Document.new(File.open(x_url))
    current=xml.elements["root/plan/current"].text.to_i
    #处理句子更改状态,根据类型不同进行不同的操作
    if is_answer=='true'
      xml_and_index=handle_sentences(xml,current,type,id,is_correct,@index,part_type,@listen_ids)
      xml=xml_and_index[:xml]
      #写入xml
      write_xml(xml,x_url)
      @index=xml_and_index[:index]
      @listen_ids=xml_and_index[:ids]
      p @listen_ids
    end
    p @index
    p @index<@listen_ids.length-1?@index+1:0
    p !(@listen_ids.empty?)
    if !(@listen_ids.empty?)
      @index=@index<@listen_ids.length-1?@index+1:0
      next_id=@listen_ids[@index]
      #获取新数据
      source=listen_write_by_id(xml,type,current,next_id,part_type)
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

  #获取听写句子的数据，复习或计划
  def listen_write_source(xml)
    part_type=UserPlan::CHAPTER_TYPE_NUM[:DICTATION].to_s #听写为5
    #获取当前正在做的计划包
    current=xml.root.elements["plan"].elements["current"].text.to_i
    p ("root/review/_#{current}/part[@type='#{part_type}']/item[@is_pass='#{UserPlan::PLAN_STATUS[:UNFINISHED]}']")
    #复习的句子
    review_listen_sentences=[]
    #复习个数
    review_sum=0
    #获取复习听的句子
    review_listen_sentences=xml.
      get_elements("root/review/_#{current}/part[@type='#{part_type}']/item[@is_pass='#{UserPlan::PLAN_STATUS[:UNFINISHED]}']")

    review_sum=review_listen_sentences.length

    #计划要学的句子
    plan_listen_sentences=[]
    plan_sum=0
    plan_listen_sentences=xml.
      get_elements("root/plan/_#{current}/part[@type='#{part_type}']/item[@is_pass='#{UserPlan::PLAN_STATUS[:UNFINISHED]}']")
    plan_sum = plan_listen_sentences.length #新学听写总数
    #如果没有数据
    if  review_sum!=0 || plan_sum!=0
      if review_sum>0
        #获取第一个复习的听写句子
        xml_sentence,web_type = review_listen_sentences[0],"review"
      else
        if plan_sum > 0
          #获取第一个新学的听写句子
          xml_sentence,web_type = plan_listen_sentences[0],"plan"
        else
          return nil
        end
      end
      @listen_ids=get_ids(xml,web_type,current,part_type)
      p @listen_ids.to_s.gsub(/([\[\]])/i,"")
      @index=0
      listen_sentence=PracticeSentence.find(xml_sentence.attributes["id"])
      return {:listen_sentence=>listen_sentence,:web_type=>web_type}
    else
      return nil
    end
  end
  #通过id查询句子 type为review或plan current为当前包数
  def listen_write_by_id(xml,web_type,current,id,part_type)
    source=xml.get_elements("root/#{web_type}/_#{current}/part[@type='#{part_type}']/item[@id='#{id}']")[0]
    listen_sentence=PracticeSentence.find(source.attributes["id"].to_i)
    return {:listen_sentence=>listen_sentence,:web_type=>web_type}
  end
  #处理句子 id 当前做的题目id is_correct答题正确和错误 index当前题目在总题目中的索引 ids当前所有题目的id
  def handle_sentences(xml,current,type,id,is_correct,index,part_type,ids)
    #找到句子
    sentence=xml.elements["root/#{type}/_#{current}/part[@type='#{part_type}']/item[@id='#{id}']"]

    #如果答对了就修改step+1和is_pass='1'
    if is_correct=='true'
      #获取repeat_time,如果不为0，则减一,不修改step和is_pass
      repeat_time=sentence.attributes["repeat_time"].to_i
      if repeat_time==0
        #改step和is_pass
        step=sentence.attributes["step"].to_i+1
        sentence.add_attribute("step",step.to_s)
        sentence.add_attribute("is_pass",UserPlan::PLAN_STATUS[:FINISHED].to_s)
        #从ids中删除已经答对的 ,index-1
        ids.delete(id)
        index=index-1
      else
        #只改repeat_time
        repeat_time=repeat_time-1
        sentence.add_attribute("repeat_time",repeat_time.to_s)
      end
      #答错，修改repeat_time=1
    else
      sentence.add_attribute("repeat_time",'1')
    end
    return {:xml=>xml,:index=>index,:ids=>ids}
  end
  #获取句子的id,type为review或plan current为当前包数 part_type为题目类型
  def get_ids(xml,type,current,part_type)
    items=xml.get_elements("root/#{type}/_#{current}/part[@type='#{part_type}']/item[@is_pass='#{UserPlan::PLAN_STATUS[:UNFINISHED]}']")
    ids=[]
    items.each do |i|
      ids<<i.attributes["id"].to_i
    end
    return ids
  end
  #更改part的status  part_type为xml部分的类型 --听写 5
  def change_part_status(xml,type,current,part_type)
    part=xml.elements["root/#{type}/_#{current}/part[@type='#{part_type}']"]
    part.add_attribute("status",'1')
    return xml
  end

  #-----End------听写过程------End------
end
