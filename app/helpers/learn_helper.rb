module LearnHelper
  require 'rexml/document'
  include REXML

  #将document对象生成xml文件
  def write_xml(doc, url)
    file = File.new(url, File::CREAT|File::TRUNC|File::RDWR, 0644)
    file.write(doc.to_s)
    file.close
  end

  #听写过程
  
  #获取听写句子的数据，复习或计划
  def listen_write_source(xml)
    part_type=UserPlan::CHAPTER_TYPE_NUM[:DICTATION].to_s #听写为5
    #获取当前正在做的计划包
    current=xml.root.elements["plan"].elements["current"].text.to_i
    p ("root/review/_#{current}/part[@type='#{part_type}']/item[@is_pass='false']")
    #复习的句子
    review_listen_sentences=[]
    #复习个数
    review_sum=0
    #获取复习听的句子
    review_listen_sentences=xml.
      get_elements("root/review/_#{current}/part[@type='#{part_type}']/item[@is_pass='false']")

    review_sum=review_listen_sentences.length

    #计划要学的句子
    plan_listen_sentences=[]
    plan_sum=0
    plan_listen_sentences=xml.
      get_elements("root/plan/_#{current}/part[@type='#{part_type}']/item[@is_pass='false']")
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
      $ids=get_ids(xml,web_type,current,part_type)
 
      index=0
      listen_sentence=PracticeSentence.find(xml_sentence.attributes["id"])
      return {:listen_sentence=>listen_sentence,:index=>index,:web_type=>web_type}
    else
      return nil
    end
  end
  #通过id查询句子 type为review或plan current为当前包数
  def listen_write_by_id(xml,web_type,current,id,part_type)
    source=xml.get_elements("root/#{web_type}/_#{current}/part[@type='#{part_type}']/item[@id='#{id}']")[0]
    listen_sentence=PracticeSentence.find(source.attributes["id"])
    return {:listen_sentence=>listen_sentence,:web_type=>web_type}
  end
  #处理句子 id 当前做的题目id is_correct答题正确和错误 index当前题目在总题目中的索引
  def handle_sentences(xml,current,type,id,is_correct,index,part_type)
    #找到句子
    sentence=xml.elements["root/#{type}/_#{current}/part[@type='#{part_type}']/item[@id='#{id}']"]
     
    #如果答对了就修改step+1和is_pass=true
    if is_correct=='true'
      #获取repeat_time,如果不为0，则减一,不修改step和is_pass
      repeat_time=sentence.attributes["repeat_time"].to_i
      if repeat_time==0
        #改step和is_pass
        step=sentence.attributes["step"].to_i+1
        sentence.add_attribute("step",step.to_s)
        sentence.add_attribute("is_pass",'true')
        #从ids中删除已经答对的 ,index-1
        $ids.delete(id.to_i)
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
    return {:xml=>xml,:index=>index}
  end
  #获取句子的ids,type为review或plan current为当前包数 part_type为题目类型
  def get_ids(xml,type,current,part_type)
    items=xml.get_elements("root/#{type}/_#{current}/part[@type='#{part_type}']/item[@is_pass='false']")
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
end
