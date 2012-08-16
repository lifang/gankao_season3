class LearnController < ApplicationController
  layout 'main'
  require 'rexml/document'
  include REXML

  def get_plan
    plan = UserPlan.where(["user_id = ? and category_id = ?", 2, 2]).first
    xml = REXML::Document.new(File.open(plan.plan_url)) if plan
  end

  def word_step_one
    p get_plan
    respond_to do |format|
      format.js
    end
  end

  def word_step_sec

  end

  def word_step_thir

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
