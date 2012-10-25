# encoding: utf-8
class Skill < ActiveRecord::Base
  belongs_to :user
  require 'rexml/document'
  include REXML

  #TYPES = {:LINSTEN => 1, :WORD => 2, :READ => 3, :SPEAK => 4} #听力  单词  阅读  口语
  CET_SKILL_NAME = {0 => "听力", 1 => "词汇", 2 => "阅读", 3 => "写作", 4 => "其它"}
  GRADUATE_SKILL_NAME = {0 => "翻译", 1 => "词汇", 2 => "阅读", 3 => "写作", 4 => "其它"}

  PASS = { :NOT => 0, :YES =>1 }

  #创建xml文件
  def self.xml_content(total_text)
    content = "<?xml version='1.0' encoding='UTF-8'?><skill>"
    while(total_text.length>0)
      total_con=""
      total_num=1500
      total_text[0..total_num].split("\r\n").each do |sent|
        total_num -=2+((sent.length/45+1)*45-sent.length)
      end
      total_text.slice!(0..total_num).split("\r\n").each do |str|
        total_con +="&lt;p&gt;"+ str+"&lt;/p&gt;"
      end
      content+="<next>"+total_con +"</next>"
    end
    p content
    content +="</skill>"
    return content
  end


  #写文件
  def self.write_xml(path,file_name,str_con)
    dir = "#{Rails.root}/public/#{path}"
    Dir.mkdir(dir) unless File.directory?(dir)
    url = dir + file_name
    f=File.new(url,"w+")
    f.write(xml_content(str_con).force_encoding('UTF-8'))
    f.close
  end

  def self.open_xml(url)
    dir = "#{Rails.root}/public"
    file=File.open(dir+url)
    doc=Document.new(file)
    file.close
    return doc
  end
  
end
