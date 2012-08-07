# encoding: utf-8
class UserPlan < ActiveRecord::Base
  belongs_to :category
  belongs_to :user
  require 'rexml/document'
  include REXML
  
  CHAPTER_TYPE = {:WORD => "word", :SENTENCE => "sentence", :LINSTEN => "linsten", :READ => "read",
    :TRANSLATE => "translate", :DICTATION => "dictation", :WRITE => "write"}#单词、句子、听力、阅读、翻译、听写、写作
  CHAPTER = {:cha1 => "基础", :cha2 => "综合", :cha3 => "冲刺"}

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
    practice_sentences = PracticeSentence.find(:select => "id",
      :conditions => ["category_id = ? and types = ? and level = ?",
        user_score_info.category_id, PracticeSentence::TYPES[:SENTENCE], all_start_level[1]])
    listens = PracticeSentence.find(:select => "id",
      :conditions => ["category_id = ? and types = ? and level = ?",
        user_score_info.category_id, PracticeSentence::TYPES[:LINSTEN], all_start_level[2]])
    return {:word => words, :practice_sentences => practice_sentences, :listens => listens}
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
  def xml_content(tiku_hash)
    content = "<?xml version='1.0' encoding='UTF-8'?>"
    content += <<-XML
      <root>
        <plan>
            <current>1</current>
            <info>
                <chapter1 word='20' sentence='6' linsten='5' days='22' />
                <chapter2 read='5' translate='5' dictation='3' days='24' />
                <chapter3 write='1' days='23' />
            </info>
        </plan>
    XML

    content += <<-XML
        <tiku>
    XML
    
    content += <<-XML
        </tiku>
      </root>
    XML

    return content
  end


end
