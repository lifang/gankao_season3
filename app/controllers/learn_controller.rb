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
